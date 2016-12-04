module Purchaser

  def buy_company company, price
    @cash -= price

    if company.owner
      company.owner.cash += price
      company.owner.companies.delete company
    end

    company.owner = self
    @companies << company
  end

end
