Code.require_file "test_helper.exs", __DIR__

defmodule DBI.ResultTest do
  use ExUnit.Case

  test "result column index" do
    assert DBI.Result.new(columns: ["col1", "col2", "col3"]).index("col2") == 1
  end

  test "zip the entire result" do
    result = DBI.Result.new(columns: ["col1", "col2", "col3"],
                            rows: [{"r1", "r1", "r1"},
                                   {"r2", "r2", "r2"},
                                   {"r3", "r3", "r3"},
                                  ])
    assert result.zip == [[{"col1", "r1"}, {"col2", "r1"}, {"col3", "r1"}],
                          [{"col1", "r2"}, {"col2", "r2"}, {"col3", "r2"}],
                          [{"col1", "r3"}, {"col2", "r3"}, {"col3", "r3"}],
    ]
  end

  test "zip a row" do
    result = DBI.Result.new(columns: ["col1", "col2", "col3"])
    assert result.zip({"r1", "r1", "r1"}) == [{"col1", "r1"}, {"col2", "r1"}, {"col3", "r1"}]
  end

  test "zip with specified columns" do
    result = DBI.Result.new(columns: ["col1", "col2", "col3"],
                            rows: [{"r1.1", "r1.2", "r1.3"},
                                   {"r2.1", "r2.2", "r2.3"},
                                   {"r3.1", "r3.2", "r3.3"},
                                  ])
    assert result.zip(["col1", "col3"]) == [[{"col1", "r1.1"}, {"col3", "r1.3"}],
                                            [{"col1", "r2.1"}, {"col3", "r2.3"}],
                                            [{"col1", "r3.1"}, {"col3", "r3.3"}]]
  end

  test "zip with specified single column" do
    result = DBI.Result.new(columns: ["col1", "col2", "col3"],
                            rows: [{"r1.1", "r1.2", "r1.3"},
                                   {"r2.1", "r2.2", "r2.3"},
                                   {"r3.1", "r3.2", "r3.3"},
                                  ])
    assert result.zip("col2") == ["r1.2", "r2.2", "r3.2"]
  end

  test "result should be an enumerable" do
    rows = [{"r1", "r1", "r1"},
            {"r2", "r2", "r2"},
            {"r3", "r3", "r3"},
    ]
    result = DBI.Result.new(columns: ["col1", "col2", "col3"],
                            rows: rows)
    assert Enum.to_list(result) == rows
  end

end
