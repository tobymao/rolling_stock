module Purchaser

  def buy_company company, price
    # deduct cost of company
    @cash -= price

    # deduct add cash to seller's account
    company.owner.cash += price

    # remove from seller
    company.owner.companies.remove company

    # reassign company's owner
    company.owner = self

    # add to your collection
    @companies << company
  end

end
