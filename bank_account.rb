require 'csv'
require 'date'

class BankTransaction

  attr_reader :amount, :account, :summary

  def initialize ( transaction_hash )
    @amount = transaction_hash["Amount"]
    @account = transaction_hash["Account"]
    deposit? ? ( transaction_hash["type"] = "DEPOSIT" ) : ( transaction_hash["type"] = "WITHDRAWAL" )
    transaction_hash["Date"] = Date.strptime("#{transaction_hash["Date"]}", '%m/%d/%Y')
    @summary = transaction_hash
  end

  def deposit?

    if amount.to_f > 0
      true
    else
      false
    end

  end

  def summary

    @summary

  end

end

class BankAccount

  attr_reader :starting_balance
  attr_accessor :summary, :current_balance, :recieve, :transactions

  def initialize (name, starting_balance)
    @name = name
    @starting_balance = starting_balance.to_f
    @current_balance = starting_balance.to_f
    @transactions = []
  end


  def starting_balance
    @starting_balance
  end

  def name
    @name
  end

  def transactions
    @transactions
  end

  def current_balance
    @current_balance
  end

  def recieve(transaction)
    @current_balance += transaction.amount.to_f
    @transactions << transaction.summary
    @transactions = transactions.sort_by {|hash| hash["Date"] }
  end

  def summary
    result = ""
    @transactions.each do |item|
      amount = "%-15s" % item["Amount"]
      type = "%-15s" % item["type"]
      result += "#{amount} #{type}     #{item["Date"].strftime('%m/%d/%Y')} - #{item["Description"]}\n"
    end
    result
  end

end

class Bank

  attr_reader :accounts

  def initialize
    @accounts = create_accounts("balances.csv", "Account", "Balance")
    load_transactions_into_account("bank_data.csv", accounts)
  end

  def create_accounts(csv, name, starting_balance)
    accounts = []
    CSV.foreach(csv, headers: true ) do |row|
      accounts << BankAccount.new(row[name], row[starting_balance])
    end
    accounts
  end

  def load_transactions_into_account(csv, account_objects)
    CSV.foreach(csv, headers: true ) do |row|
      transaction = BankTransaction.new(row.to_hash)
      account_objects.each do |account|
        if account.name == transaction.account
          account.recieve(transaction)
        end
      end
    end
  end

  def report
    accounts.each do |account|
      puts "==========#{account.name}=========="
      puts "Starting Balance: " + account.starting_balance.to_s
      puts "Current Balance: " + account.current_balance.to_s
      puts
      puts account.summary
      puts "========================================"
      puts
    end
  end


end

