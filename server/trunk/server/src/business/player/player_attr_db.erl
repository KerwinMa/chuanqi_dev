%%%-------------------------------------------------------------------
%%% @author zhengsiying
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 八月 2015 下午3:09
%%%-------------------------------------------------------------------
-module(player_attr_db).

-include("common.hrl").
-include("cache.hrl").

%% API
-export([
	select_row/1,
	insert/1,
	update/2
]).

%% ====================================================================
%% API functions
%% ====================================================================
select_row(PlayerId) ->
	case db:select_row(player_attr, record_info(fields, db_player_attr), [{player_id, PlayerId}]) of
		[] ->
			null;
		List ->
			list_to_tuple([db_player_attr | List])
	end.

insert(PlayerMoney) ->
	db:insert(player_attr, util_tuple:to_tuple_list(PlayerMoney)).

update(PlayerId, PlayerMoney) ->
	db:update(player_attr, util_tuple:to_tuple_list(PlayerMoney), [{player_id, PlayerId}]).
