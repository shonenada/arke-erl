-module(arke_logger).

-export([lager_console_backend/0]).

lager_console_backend() ->
    {lager_console_backend,
     [{level, debug},
      {formatter, stout},
      {formatter_config, [{time, yellow}," ",
                          {severity, [upper, color, {format, "~s"}]}," ",
                          {application, [{format, "(~s) "}, magentab]},
                          message, " ",
                          {pid, cyan}," ",
                          {module,[{format,"~s"},blackb]},
                          {function,[{format,":~s"},blackb]},
                          {line,[{format,"/~b"},blackb]}, "\n"]}]} .
