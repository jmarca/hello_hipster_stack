use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hello_hipster_stack, HelloHipsterStackWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :hello_hipster_stack, HelloHipsterStack.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "hello_hipster_stack_test",
  hostname: "localhost",
  port: 6543,
  pool: Ecto.Adapters.SQL.Sandbox
