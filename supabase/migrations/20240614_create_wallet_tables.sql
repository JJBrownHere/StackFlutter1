-- Create wallets table
create table public.wallets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  balance decimal(10,2) default 0 not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint positive_balance check (balance >= 0)
);

-- Create wallet transactions table
create table public.wallet_transactions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  amount decimal(10,2) not null,
  type text not null check (type in ('credit', 'debit')),
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create indexes
create index wallets_user_id_idx on public.wallets(user_id);
create index wallet_transactions_user_id_idx on public.wallet_transactions(user_id);
create index wallet_transactions_created_at_idx on public.wallet_transactions(created_at);

-- Enable Row Level Security
alter table public.wallets enable row level security;
alter table public.wallet_transactions enable row level security;

-- Create policies
create policy "Users can view their own wallet"
  on public.wallets for select
  using (auth.uid() = user_id);

create policy "Users can view their own transactions"
  on public.wallet_transactions for select
  using (auth.uid() = user_id);

-- Create function to handle wallet balance updates
create or replace function public.handle_wallet_balance()
returns trigger as $$
begin
  if new.type = 'debit' then
    update public.wallets
    set balance = balance - new.amount,
        updated_at = now()
    where user_id = new.user_id;
  elsif new.type = 'credit' then
    update public.wallets
    set balance = balance + new.amount,
        updated_at = now()
    where user_id = new.user_id;
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger for wallet transactions
create trigger on_wallet_transaction
  after insert on public.wallet_transactions
  for each row
  execute function public.handle_wallet_balance(); 