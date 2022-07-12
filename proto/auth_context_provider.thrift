namespace java dev.vality.orgmanagement
namespace erlang orgmgmt.authctx_provider

include "domain.thrift"
include "proto/context.thrift"

exception UserNotFound {}

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
     * [1]: https://github.com/valitydev/bouncer-proto/blob/97dcad6f/proto/context_v1.thrift#L78
     */
    context.ContextFragment GetUserContext (1: domain.UserID id) throws (
        1: UserNotFound ex1
    )

}
