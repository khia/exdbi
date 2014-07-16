defmodule DBI.Result do
  defstruct count: nil, columns: [], rows: []
  @type t :: %{__struct__: __MODULE__}

  def zip(%__MODULE__{columns: columns}, row) when is_tuple(row) and
      tuple_size(row) == length(columns) do
    Enum.zip(columns, Tuple.to_list(row))
  end
  def zip(%__MODULE__{columns: columns, rows: rows}, column) when is_binary(column) do
    idx = Enum.find_index(columns, &(&1 == column))
    for row <- rows, do: elem(row, idx)
  end

  def zip(%__MODULE__{columns: columns, rows: rows}, requested_columns) when is_list(requested_columns) do
    indexes = Enum.filter_map(Enum.with_index(columns),
      fn({column, _idx}) -> column in requested_columns end,
      fn(ci) -> ci end)
    for row <- rows do
      for {column, idx} <- indexes, do: {column, elem(row, idx)}
    end
  end

  def zip(%__MODULE__{columns: columns, rows: rows}) do
    for row <- rows, do: Enum.zip(columns, Tuple.to_list(row))
  end

  def index(%__MODULE__{columns: columns}, column) do
    Enum.find_index(columns, &(&1 == column))
  end
end

defimpl Enumerable, for: DBI.Result do

  alias DBI.Result, as: T

  def count(%T{rows: rows}), do: {:ok, length(rows)}
  def member?(%T{rows: rows}, row), do: {:ok, Enum.member?(rows, row)}

  def reduce(%T{rows: [h|t]} = result, {:cont, acc}, fun) do
    reduce(%{result | rows: t}, fun.(h, acc), fun)
  end
  def reduce(%T{rows: []}, {:cont, acc}, _fun), do: {:done, acc}
  def reduce(%T{}, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(%T{} = t, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(t, &1, fun)}
end