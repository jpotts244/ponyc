use "cli"

actor Main
  new create(env: Env) =>
    try
      let cmd =
        match CommandParser(cli_spec()?).parse(env.args, env.vars())
        | let c: Command => c
        | let ch: CommandHelp =>
            ch.print_help(env.out)
            env.exitcode(0)
            return
        | let se: SyntaxError =>
            env.out.print(se.string())
            env.exitcode(1)
            return
        end

        // cmd is a valid Command, now use it.

    end

  fun tag cli_spec(): CommandSpec box ? =>
    """
    Builds and returns the spec for a sample chat client's CLI.
    """
    let cs = CommandSpec.parent("chat", "A sample chat program", [
      OptionSpec.bool("admin", "Chat as admin" where default' = false)
      OptionSpec.string("name", "Your name" where short' = 'n')
      OptionSpec.i64("volume", "Chat volume" where short' = 'v')
    ], [
      CommandSpec.leaf("say", "Say something", Array[OptionSpec](), [
        ArgSpec.string("words", "The words to say")
      ])?
      CommandSpec.leaf("emote", "Send an emotion", [
        OptionSpec.f64("speed", "Emote play speed" where default' = F64(1.0))
      ], [
        ArgSpec.string("emotion", "Emote to send")
      ])?
      CommandSpec.parent("config", "Configuration commands", Array[OptionSpec](), [
        CommandSpec.leaf("server", "Server configuration", Array[OptionSpec](), [
          ArgSpec.string("address", "Address of the server")
        ])?
      ])?
    ])?
    cs.add_help()?
    cs
