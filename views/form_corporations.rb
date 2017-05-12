require './views/base'

module Views
  class FormCorporations < Action
    needs :current_player
    needs :game

    def render_action
      company = game.acting.first
      widget EntityOrder, game: game, entities: game.player_companies
      widget Companies, companies: game.acting

      share_prices = game.share_prices.reject do |share_price|
        share_price.corporation || !company.valid_share_price?(share_price)
      end

      render_info_table company, share_prices

      game_form do
        select name: data('corporation') do
          game.available_corporations.each do |corporation|
            option(value: corporation) { text corporation }
          end
        end

        select name: data('price') do
          share_prices.each do |share_price|
            next if ::Corporation.initial_shares_info(
              company,
              share_price.price
            )[:seed] > current_player.cash

            option(value: share_price.price) { text "$#{share_price.price}" }
          end
        end

        input id: 'form_company', type: 'hidden', name: data('company'), value: company.name
        input id: 'form_submit', type: 'submit', value: 'Form Corporation'
      end if game.can_act? current_player

      render_company_descriptions if game.v2?
    end

    def render_info_table company, share_prices
      div style: table_style do
        div style: inline(display: 'table-row', font_weight: 'bold') do
          render_column 'Price'
          render_column 'Shares Issued'
          render_column 'Money Spent'
          render_column 'Treasury'
        end

        share_prices.each do |share_price|
          price = share_price.price
          info = ::Corporation.initial_shares_info company, price

          div style: inline(display: 'table-row') do
            render_column "$#{share_price.price}"
            render_column "#{info[:num_shares] * 2}"
            render_column "$#{info[:seed]}"
            render_column "$#{info[:cash]}"
          end
        end
      end
    end

    def render_company_descriptions
      div style: table_style do
        div style: inline(display: 'table-row', font_weight: 'bold') do
          render_column 'Company'
          render_column 'Shares'
          render_column 'Super Power'
        end

        klass = ::CorporationV2
        corporations =  klass::CORPORATIONS
          .map { |name| [name, klass.starting_shares(name), klass.super_power(name)] }
          .sort_by { |name, shares| [shares, name] }

        corporations.each do |name, shares, super_power|
          div style: inline(display: 'table-row') do
            render_column name
            render_column shares
            render_column super_power
          end
        end
      end
    end

    def render_column data
      col_style = inline(
        margin: '5px',
        display: 'table-cell',
        text_align: 'right',
      )
      div(style: col_style) { text data }
    end

    def table_style
      table_style = inline(
        display: 'table',
        width: '320px',
        margin: '5px 0 5px',
      )
    end

  end
end
