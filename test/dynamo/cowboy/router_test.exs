Code.require_file "../../../test_helper", __FILE__

defmodule Dynamo.Cowboy.RouterTest do
  use ExUnit.Case

  defmodule RouterApp do
    use Dynamo.Router

    get "/foo/bar" do
      response.reply(200, [], "Hello World!")
    end

    get "/mounted" do
      response.reply(200, [], request.path)
    end

    mount __MODULE__, at: "/baz"
  end

  def setup_all do
    Dynamo.Cowboy.run RouterApp, port: 8012, verbose: false
  end

  def teardown_all do
    Dynamo.Cowboy.shutdown RouterApp
  end

  test "basic request on a router app" do
    assert_match { 200, _, "Hello World!" }, http_client.request :get, "/foo/bar"
  end

  test "basic request on a mounted app" do
    assert_match { 200, _, "/mounted" }, http_client.request :get, "/baz/mounted"
  end

  test "404 response a router app" do
    assert_match { 404, _, "" }, http_client.request :get, "/other"
  end

  defp http_client do
    HTTPClient.new("http://127.0.0.1:8012")
  end
end

