%%%-------------------------------------------------------------------
%%% @author zhengsiying
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 七月 2015 下午2:56
%%%-------------------------------------------------------------------
-module(scene_mod).


-behaviour(gen_server).

-include("common.hrl").
-include("record.hrl").

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%% API
-export([
	start/3,
	start/2,
	stop/1
]).
%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
start(SceneId,LineNum) ->
	gen_server:start(?MODULE, [SceneId,LineNum], []).
start(SceneId, PlayerState,LineNum) ->
	gen_server:start(?MODULE, [SceneId, PlayerState,LineNum], []).

stop(State) ->
	{stop, shutdown, State}.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
	{ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term()} | ignore).
init([SceneId,LineNum]) ->
	process_flag(trap_exit, true),
	SceneState = scene_base_lib:init(SceneId,LineNum),
	{ok, SceneState};
init([SceneId, PlayerState,LineNum]) ->
	process_flag(trap_exit, true),
	SceneState = scene_base_lib:init(SceneId, PlayerState,LineNum),
	{ok, SceneState}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
	State :: #state{}) ->
	{reply, Reply :: term(), NewState :: #state{}} |
	{reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
	{stop, Reason :: term(), NewState :: #state{}}).
%% 执行同步apply操作
handle_call({apply_sync, {F}}, _From, State) ->
	handle_apply_sync_return(util_sys:apply_catch(F, [State]), {undefined, F, []}, State);
handle_call({apply_sync, {F, A}}, _From, State) ->
	handle_apply_sync_return(util_sys:apply_catch(F, [State | A]), {undefined, F, A}, State);
handle_call({apply_sync, {M, F, A}}, _From, State) ->
	handle_apply_sync_return(util_sys:apply_catch(M, F, [State | A]), {M, F, A}, State);

handle_call({get, Args}, _From, State) ->
	Reply = util_sys:apply_catch(erlang, get, Args),
	{reply, Reply, State};
handle_call({put, [Index, Value]}, _From, State) ->
	put(Index, Value),
	{reply, ok, State};

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
	{noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #state{}}).
%% 执行异步apply操作
handle_info({apply_async, {F}}, State) ->
	handle_apply_async_return(util_sys:apply_catch(F, [State]), {undefined, F, []}, State);
handle_info({apply_async, {F, A}}, State) ->
	handle_apply_async_return(util_sys:apply_catch(F, [State | A]), {undefined, F, A}, State);
handle_info({apply_async, {M, F, A}}, State) ->
	handle_apply_async_return(util_sys:apply_catch(M, F, [State | A]), {M, F, A}, State);
handle_info(_Info, State) ->
	{noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
	State :: #state{}) -> term()).
terminate(_Reason, _State) ->
	case _Reason of
		shutdown ->
			skip;
		_ ->
			scene_mgr_lib:close_scene(self())
	end,
	ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
	Extra :: term()) ->
	{ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% 处理同步apply的返回值
handle_apply_sync_return({ok, Reply, State}, _Mfa, _OldState) ->
	{reply, {ok, Reply}, State};
handle_apply_sync_return({ok, Reply}, _Mfa, State) ->
	{reply, {ok, Reply}, State};
handle_apply_sync_return({stop, Reason, State}, _Mfa, _OldState) ->
	{stop, Reason, State};
handle_apply_sync_return(Else, _Mfa, State) ->
	{reply, Else, State}.

%% 处理异步apply的返回值
handle_apply_async_return({ok, State}, _Mfa, _OldState) ->
	{noreply, State};
handle_apply_async_return(ok, _Mfa, State) ->
	{noreply, State};
handle_apply_async_return({stop, Reason, State}, _Mfa, _OldState) ->
	{stop, Reason, State};
handle_apply_async_return(_Else, _Mfa, State) ->
	{noreply, State}.