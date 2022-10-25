defmodule OrgManagementProto.MixProject do
  use Mix.Project

  def project do
    [
      app: :org_management_proto,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:thrift, :woody | Mix.compilers],
      thrift: [
        files: Path.wildcard("proto/*.thrift"),
        include_paths: [Path.join(base_deps_path(), "bouncer_proto")]
      ]
    ]
  end

  def application, do: []

  defp deps do
    [
      {:bouncer_proto, git: "https://github.com/valitydev/bouncer-proto.git", branch: "master"},
      {:thrift, git: "https://github.com/pinterest/elixir-thrift", branch: "master"},
      {:woody_ex, git: "https://github.com/valitydev/woody_ex.git", branch: "ft/thrift-elixir"}
    ]
  end

  defp base_deps_path do
    alias Mix.{Project, ProjectStack}
    # Why
    case ProjectStack.top_and_bottom() do
      nil -> Project.deps_path()
      {_, project} -> Path.join(Path.dirname(project[:file]), "deps")
    end
  end
end
