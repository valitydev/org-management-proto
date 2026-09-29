namespace java dev.vality.orgmanagement
namespace erlang orgmgmt.authctx_provider
namespace elixir OrgManagement.AuthContextProvider

include "domain.thrift"
include "proto/context.thrift"

exception UserNotFound {}
exception PartyNotFound {}

/**
 * Сервис, предоставляющий bouncer-контексты для задач авторизации.
 */
service AuthContextProvider {

    /**
     * Получить контекст пользователя по его идентификатору.
     *
     * Предполагается, что контекст будет содержать информацию о пользователе, которую можно
     * уместить в [`context_v1.User`][1].
     *
     * [1]: https://github.com/valitydev/bouncer-proto/blob/master/proto/context_v1.thrift#L112
     */
    context.ContextFragment GetUserContext (1: domain.UserID id) throws (
        1: UserNotFound ex1
    )

    /**
     * Получить контекст участника по его идентификатору.
     *
     * Предполагается, что контекст будет содержать информацию о участнике, которую можно
     * уместить в [`context_v1.Party`][1].
     *
     * [1]: https://github.com/valitydev/bouncer-proto/blob/master/proto/context_v1.thrift#L145
     */
    context.ContextFragment GetPartyContext (1: domain.PartyID id) throws (
        1: PartyNotFound ex1
    )
}
