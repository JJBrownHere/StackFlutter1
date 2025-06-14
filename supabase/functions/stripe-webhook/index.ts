import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || '', {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') || '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
)

serve(async (req) => {
  const signature = req.headers.get('stripe-signature')
  if (!signature) {
    return new Response(
      JSON.stringify({ error: 'No signature' }),
      { status: 400 }
    )
  }

  try {
    const body = await req.text()
    const event = stripe.webhooks.constructEvent(
      body,
      signature,
      Deno.env.get('STRIPE_WEBHOOK_SECRET') || ''
    )

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object
      const userId = session.metadata.userId
      const amount = session.amount_total / 100 // Convert from cents

      // Update wallet balance
      const { data: wallet } = await supabaseClient
        .from('wallets')
        .select('balance')
        .eq('user_id', userId)
        .single()

      const newBalance = (wallet?.balance || 0) + amount

      await supabaseClient
        .from('wallets')
        .upsert({
          user_id: userId,
          balance: newBalance,
          updated_at: new Date().toISOString(),
        })

      // Record transaction
      await supabaseClient
        .from('wallet_transactions')
        .insert({
          user_id: userId,
          amount: amount,
          type: 'credit',
          description: 'Added funds via Stripe',
          created_at: new Date().toISOString(),
        })
    }

    return new Response(
      JSON.stringify({ received: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400 }
    )
  }
}) 