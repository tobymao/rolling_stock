class Purchaser
  attr_reader :companies, :income, :base_income, :cost_of_ownership
  attr_accessor :cash, :pending_cash

  def initialize cash
    @cash = cash
    @pending_cash = 0
    @companies = []
    @income = 0
    @base_income = 0
    @cost_of_ownership = 0
  end

  def pp_cash
    str = String.new "$#{@cash}"
    str << " ($#{@pending_cash})" if @pending_cash > 0
    str
  end

  def buy_company company, price
    old_owner = company.owner
    raise GameException, "Can't buy own company" if old_owner == self
    raise GameException, "You don't have enough money to buy at that price" if @cash < price
    raise GameException, "Company can't be sold. Last company or just sold" unless company.can_be_sold?

    @cash -= price
    old_owner.pending_cash += price if old_owner.respond_to? :pending_cash
    old_owner.companies.delete company
    company.recently_sold = true
    company.owner = self
    @companies << company
    set_income old_owner

    @log << "#{name} buys #{company.name} for $#{price} from #{owner&.name}"
  end

  def close_company company
    raise GameException, "#{name} does not own #{company.name}" unless @companies.include? company

    if company.owner.is_a?(Corporation) && company.owner.companies.size == 1
      raise GameException, "Can't close last company"
    end

    @companies.delete company
    set_income
    @log << "#{name} closes #{company.name}"
  end

  def set_income old_owner = nil
    oo = old_owner || owner
    oo.set_income if oo != self && oo.respond_to?(:set_income)
    @base_income = @companies.map(&:income).reduce(&:+) || 0
    @cost_of_ownership = @companies.map { |c| c.cost_of_ownership }.reduce(&:+) || 0
    @income = @base_income - @cost_of_ownership
  end

  def collect_income
    @cash += income
    @log << "#{name} collects $#{income} income"
  end

  def negative_income?
    (@cash + @income) < 0
  end

  def finalize_purchases
    @cash += @pending_cash
    @pending_cash = 0
    @companies.each { |c| c.recently_sold = false }
  end
end
