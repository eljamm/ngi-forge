{
  config,
  pkgs,
  ...
}:

let
  app = config.apps.docspec;
in

{
  apps.docspec = {
    displayName = "DocSpec";
    description = "Document conversion SDK for rich text formats.";
    usage = ''
      First, [launch the shell envrionment](app/${app.name}#run-shell) containing `${app.name}`.

      Then, clone the project repository:

      ```bash
      git clone ${app.links.source} docspec
      cd docspec/tests/fixtures
      ```

      Next, convert one of the test documents to a BlockNote JSON, since it's currently the best-supported output format:

      ```bash
      docspec convert docx/docspec/preformatted-boundaries.docx --output blocknote.json
      ```

      For a list of supported formats and their status, run:

      ```bash
      docspec convert --help
      ```
    '';

    links = {
      website = "https://github.com/docspec/docspec";
      source = "https://github.com/docspec/docspec";
      docs = null;
    };

    ngi.grants = {
      Commons = [
        "DocSpec-WASM"
      ];
    };

    programs = {
      mainPackage = pkgs.docspec;
      packages = [ pkgs.docspec ];

      runtimes = {
        shell.enable = true;
        program.enable = true;
      };
    };
  };
}
