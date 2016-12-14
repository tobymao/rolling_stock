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
    @cash += income(tier)
  end

  def income tier
    @companies
      .map { |c| c.income - c.cost_of_ownership(tier) }
      .reduce(&:+) || 0
  end
end
