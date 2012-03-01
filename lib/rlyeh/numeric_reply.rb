module Rlyeh
  module NumericReply
    class << self
      def map
        @map ||= {
          # Numerics in the range from 001 to 099 are used for client-server
          # connections only and should never travel between servers.
          # Replies generated in the response to commands are found in the range from 200 to 399.
          :welcome => 1,
          :yourhost => 2,
          :created => 3,
          :myinfo => 4,
          :bounce => 5,
          :userhost => 302,
          :ison => 303,
          :away => 301,
          :unaway => 305,
          :nowaway => 306,
          :whoisuser => 311,
          :whoisserver => 312,
          :whoisoperator => 313,
          :whoisidle => 317,
          :endofwhois => 318,
          :whoischannels => 319,
          :whowasuser => 314,
          :endofwhowas => 369,
          :liststart => 321,
          :list => 322,
          :listend => 323,
          :uniqopis => 325,
          :channelmodeis => 324,
          :notopic => 331,
          :topic => 332,
          :inviting => 341,
          :summoning => 342,
          :invitelist => 346,
          :endofinvitelist => 347,
          :exceptlist => 348,
          :endofexceptlist => 349,
          :version => 351,
          :whoreply => 352,
          :endofwho => 315,
          :namreply => 353,
          :endofnames => 366,
          :links => 364,
          :endoflinks => 365,
          :banlist => 367,
          :endofbanlist => 368,
          :info => 371,
          :endofinfo => 374,
          :motdstart => 375,
          :motd => 372,
          :endofmotd => 376,
          :youreoper => 381,
          :rehashing => 382,
          :youreservice => 383,
          :time => 391,
          :usersstart => 392,
          :users => 393,
          :endofusers => 394,
          :nousers => 395,
          :tracelink => 200,
          :traceconnecting => 201,
          :tracehandshake => 202,
          :traceunknown => 203,
          :traceoperator => 204,
          :traceuser => 205,
          :traceserver => 206,
          :traceservice => 207,
          :tracenewtype => 208,
          :traceclass => 209,
          :tracereconnect => 210,
          :tracelog => 261,
          :traceend => 262,
          :statslinkinfo => 211,
          :statscommands => 212,
          :endofstats => 219,
          :statsuptime => 242,
          :statsoline => 243,
          :umodeis => 221,
          :servlist => 234,
          :servlistend => 235,
          :luserclient => 251,
          :luserop => 252,
          :luserunknown => 253,
          :luserchannels => 254,
          :luserme => 255,
          :adminme => 256,
          :adminloc1 => 257,
          :adminloc2 => 258,
          :adminemail => 259,
          :tryagain => 263,

          # Error replies are found in the range from 400 to 599.
          :nosuchnick => 401,
          :nosuchserver => 402,
          :nosuchchannel => 403,
          :cannotsendtochan => 404,
          :toomanychannels => 405,
          :wasnosuchnick => 406,
          :toomanytargets => 407,
          :nosuchservice => 408,
          :noorigin => 409,
          :norecipient => 411,
          :notexttosend => 412,
          :notoplevel => 413,
          :wildtoplevel => 414,
          :badmask => 415,
          :unknowncommand => 421,
          :nomotd => 422,
          :noadmininfo => 423,
          :fileerror => 424,
          :nonicknamegiven => 431,
          :erroneusnickname => 432,
          :nicknameinuse => 433,
          :nickcollision => 436,
          :unavailresource => 437,
          :usernotinchannel => 441,
          :notonchannel => 442,
          :useronchannel => 443,
          :nologin => 444,
          :summondisabled => 445,
          :usersdisabled => 446,
          :notregistered => 451,
          :needmoreparams => 461,
          :alreadyregistred => 462,
          :nopermforhost => 463,
          :passwdmismatch => 464,
          :yourebannedcreep => 465,
          :youwillbebanned => 466,
          :keyset => 467,
          :channelisfull => 471,
          :unknownmode => 472,
          :inviteonlychan => 473,
          :bannedfromchan => 474,
          :badchannelkey => 475,
          :badchanmask => 476,
          :nochanmodes => 477,
          :banlistfull => 478,
          :noprivileges => 481,
          :chanoprivsneeded => 482,
          :cantkillserver => 483,
          :restricted => 484,
          :uniqopprivsneeded => 485,
          :nooperhost => 491,
          :umodeunknownflag => 501,
          :usersdontmatch => 502,
        }
      end

      def map_invert
        @map_invert ||= map.invert
      end

      def to_value(value)
        case value
        when Integer
          numeric_to_value value
        when Symbol
          name_to_value value
        else
          str = value.to_s
          begin
            numeric = Integer(str)
            numeric_to_value numeric
          rescue ArgumentError
            name_to_value str
          end
        end
      end

      def to_key(value)
        case value
        when Integer
          numeric_to_key value
        when Symbol
          name_to_key value
        else
          str = value.to_s
          begin
            numeric = Integer(str)
            numeric_to_key numeric
          rescue ArgumentError
            name_to_key str
          end
        end
      end

      def numeric_to_value(numeric)
        numeric.to_s.rjust(3, '0')
      end

      def numeric_to_key(numeric)
        map_invert[numeric]
      end

      def name_to_value(name)
        numeric_to_value map[name.intern]
      end

      def name_to_key(name)
        name.intern
      end
    end
  end
end
