module Purchaser
  def buy_company company, price
    @cash -= price
    owner = company.owner
    owner.cash += price if owner.respond_to? :cash
    owner.companies.delete company

    company.owner = self
    @companies << company
  end

  def close_company company
    @companies.delete company
  end

  def collect_income tier
    @companies.each do |company|
      @cash += company.income
      @cash -= company.cost_of_ownership tier
    end
  end
end
