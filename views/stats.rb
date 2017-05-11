require './views/base'

module Views
  class Stats < Page
    needs :game

    def render_head
      super
      script src: 'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.4.0/Chart.min.js'
    end

    def page_title
      "Game #{game.id} Statistics"
    end

    def render_main
      graph_style = inline(
        max_width: 'calc(100% - 40px)',
        max_height: 'calc(100%)',
      )

      div class: 'wrapper' do
        a 'Back To Game', href: app.path(game), style: inline(margin_left: '10px')
        canvas id: 'graph', style: graph_style
      end

      rounds = []
      players = {}

      company_class = game.company_class
      game.players.sort_by(&:name).each_with_index do |player, index|
        players[index] = {
          label: player.name,
          data: [],
          borderColor: company_class.color_for_tier(company_class::TIERS[index]),
          fill: false,
          lineTension: 0,
        }
      end

      game.stats.each do |data|
        rounds << data[0]
        data.drop(1).each_with_index { |v, i| players[i][:data] << v }
      end

      script <<~JS
        var ctx = $('#graph');

        var myChart = new Chart(ctx, {
          type: 'line',
          data: {
            labels: #{JSON.dump rounds},
            datasets: #{JSON.dump players.values},
          },
          options: {
            responsive: true,
            elements: { point: { radius: 0 } },
            scales: {
              yAxes: [{
                type: 'logarithmic',
                ticks: {
                  callback: function(value, index, values) { return "$" + value; },
                },
              }],
              xAxes: [{
                ticks: {
                  autoSkip: true,
                  maxTicksLimit: 40,
                }
              }],
            }
          }
        });
      JS
    end

  end
end
