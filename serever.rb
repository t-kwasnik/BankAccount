require 'sinatra'
require_relative 'bank_account.rb'

bank = Bank.new

get "/accounts/:account" do
  account = params[:account].gsub("+"," ")
  bank.accounts.each do |a|
    if a.name == account
      @starting_balance = a.starting_balance
      @current_balance = a.current_balance
      @transactions = a.transactions
    end
  end

  erb :account
end

get "/accounts" do

  @accounts = []

  bank.accounts.each do |a|
    account_hash = {}
    account_hash["name"] = a.name
    account_hash["start"] = a.starting_balance
    account_hash["current"] = a.current_balance
    account_hash["first_trans"] = a.transactions[0]["Date"]
    account_hash["last_trans"] = a.transactions[-1]["Date"]
    @accounts << account_hash
  end

  erb :accounts
end

