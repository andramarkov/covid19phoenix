defmodule Covid19Web.Live.Components.CountrywiseSummary do
  alias Covid19Web.Live.Views.Detail

  import Phoenix.HTML
  import Phoenix.HTML.Link
  alias Covid19Web.Router.Helpers, as: Routes

  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok,
     socket
     |> assign(by: :country_or_region)
     |> assign(dir: :asc)
     |> assign(term: "")}
  end

  def handle_event("sort", %{"by" => by}, socket) do
    {:noreply,
     socket
     |> update(:dir, fn
       :asc -> :desc
       :desc -> :asc
     end)
     |> assign(by: String.to_atom(by))}
  end

  def handle_event("filter", %{"term" => term}, socket) do
    {:noreply, socket |> assign(term: term)}
  end

  def handle_event("clear-term", _, socket) do
    {:noreply, socket |> assign(term: "")}
  end

  def render(assigns) do
    ~L"""
    <div class="card">
      <div class="card-content">
        <div class="level">
          <div class="level-left">
            <p class="level-item title is-5 is-uppercase">Countrywise Summary</p>
          </div>
          <div class="level-right">
            <div class="level-item">
              <form phx-change="filter" phx-target="<%= @myself %>">
                <div class="field has-addons">
                  <div class="control has-icons-left">
                    <input name="term" class="input is-wide" type="text" placeholder="Filter by country" value="<%= @term %>">
                    <span class="icon is-small is-left">
                      <i class="fas fa-search"></i>
                    </span>
                  </div>
                  <div class="control">
                    <a phx-click="clear-term" phx-target="<%= @myself %>" class="button is-danger">
                      <i class="fas fa-trash"></i>
                    </a>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>

        <div class="table-container" style="height: 400px; overflow: auto">
          <table class="table is-striped is-narrow is-fullwidth">
            <thead>
              <tr>
                <th>#</th>
                <th>
                  <a href="#" phx-click="sort" phx-value-by="country_or_region" phx-target="<%= @myself %>">
                    Country/Region <%= show_sort_icon(:country_or_region, @by, @dir) %>
                  </a>
                </th>
                <th class="has-text-right">
                  <a href="#" phx-click="sort" phx-value-by="confirmed" phx-target="<%= @myself %>">
                    Confirmed <%= show_sort_icon(:confirmed, @by, @dir) %>
                  </a>
                </th>
                <th class="has-text-right">
                  <a href="#" phx-click="sort" phx-value-by="new_confirmed" phx-target="<%= @myself %>">
                    New Cases <%= show_sort_icon(:new_confirmed, @by, @dir) %>
                  </a>
                </th>
                <th class="has-text-right">
                  <a href="#" phx-click="sort" phx-value-by="active" phx-target="<%= @myself %>">
                    Active <%= show_sort_icon(:active, @by, @dir) %>
                  </a>
                </th>
                <th class="has-text-centered">
                  <a href="#" phx-click="sort" phx-value-by="recovered" phx-target="<%= @myself %>">
                    Recovered <%= show_sort_icon(:recovered, @by, @dir) %>
                  </a>
                </th>
                <th class="has-text-centered">
                  <a href="#" phx-click="sort" phx-value-by="deaths" phx-target="<%= @myself %>">
                    Deaths <%= show_sort_icon(:deaths, @by, @dir) %>
                  </a>
                </th>
                <th class="has-text-centered">
                  <a href="#" phx-click="sort" phx-value-by="new_deaths" phx-target="<%= @myself %>">
                    New Deaths <%= show_sort_icon(:new_deaths, @by, @dir) %>
                  </a>
                </th>
              </tr>
            </thead>
            <tbody>
              <%= for {d, idx} <- sorted(@data, @by, @dir, @term) do %>
                <tr>
                  <td><%= idx %></td>
                  <td>
                    <%= link d.country_or_region, to: Routes.live_path(@socket, Detail, d.country_or_region) %>
                  </td>
                  <td class="has-text-weight-semibold has-text-right"><%= d.confirmed |> fmt() %></td>
                  <td class="has-text-weight-semibold has-text-right"><%= d.new_confirmed |> fmt() %></td>
                  <td class="has-text-weight-semibold has-text-right"><%= d.active |> fmt() %></td>
                  <td class="has-background-primary has-text-weight-semibold has-text-centered"><%= d.recovered |> fmt() %></td>
                  <td class="has-text-weight-semibold has-text-centered"><%= d.deaths |> fmt() %></td>
                  <td class="has-background-danger has-text-weight-semibold has-text-centered"><%= d.new_deaths |> fmt() %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp fmt(number) when is_number(number) do
    Number.Delimit.number_to_delimited(number, precision: 0)
  end

  defp sorted(data, by, dir, term) do
    data
    |> Enum.sort_by(& &1[by], dir)
    |> Enum.filter(fn %{country_or_region: country_or_region} ->
      String.contains?(
        String.downcase(country_or_region),
        String.downcase(term)
      )
    end)
    |> Enum.with_index(1)
  end

  defp show_sort_icon(col, by, dir) do
    if col == by do
      case dir do
        :asc ->
          ~E"""
            <i class="fas fa-long-arrow-alt-up"></i>
          """

        _ ->
          ~E"""
            <i class="fas fa-long-arrow-alt-down"></i>
          """
      end
    end
  end
end
