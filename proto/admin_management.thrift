namespace java dev.vality.orgmanagement
namespace erlang orgmgmt.admin_management
namespace elixir OrgManagement.AdminManagement

include "domain.thrift"

/** Организация не существует. */
exception OrganizationNotFound {}

/** Указанный пользователь не состоит в организации. */
exception MemberNotFound {}

/** Назначение роли не найдено в организации. */
exception MemberRoleNotFound {}

/** Приглашение не существует либо не относится к указанной организации. */
exception InvitationNotFound {}

/** Пользователь не существует. */
exception UnknownUser {}

/** Организация с указанным party_id уже существует. */
exception PartyAlreadyBound {}

/** Операцию нельзя выполнить для текущего состояния организации. */
exception InvalidOrganizationState {
    1: required string reason
}

/** Операцию нельзя выполнить для текущего состояния приглашения. */
exception InvalidInvitationState {
    1: required string reason
}

/**
 * Запрос не прошёл валидацию: некорректный JSON в metadata, пустое имя, пустой role_id
 * или scope_id.
 */
exception InvalidRequest {
    1: required string reason
}

struct CreateOrganizationRequest {
    /** Идентификатор party, для которого создаётся организация. */
    1: required domain.PartyID party_id
    /** Идентификатор владельца организации. */
    2: required domain.UserID owner_id
    3: required string name
    4: optional domain.JsonObject metadata
    5: optional set<string> allowed_ips
}

struct ListOrganizationsRequest {
    1: optional i32 limit
    2: optional domain.ContinuationToken continuation_token
    /** Если не указан, возвращаются организации всех статусов. */
    3: optional domain.OrganizationStatus status
    /** Если не указан, фильтрация по владельцу не применяется. */
    4: optional domain.UserID owner_id
}

struct ModifyOrganizationRequest {
    /** Неуказанные поля остаются без изменений. */
    1: optional string name
    2: optional domain.JsonObject metadata
    3: optional set<string> allowed_ips
}

struct ListOrganizationsResult {
    1: required list<domain.Organization> organizations
    2: optional domain.ContinuationToken continuation_token
}

struct AddMemberRequest {
    1: required domain.UserID user_id
    2: required string email
}

struct ListMembersRequest {
    1: optional i32 limit
    2: optional domain.ContinuationToken continuation_token
}

struct ListMembersResult {
    1: required list<domain.Member> members
    2: optional domain.ContinuationToken continuation_token
}

struct ListUsersRequest {
    1: optional i32 limit
    2: optional domain.ContinuationToken continuation_token
    /** Точное совпадение email; если не указан, фильтрация по email не применяется. */
    3: optional string email
}

struct ListUsersResult {
    1: required list<domain.User> users
    2: optional domain.ContinuationToken continuation_token
}

struct AssignMemberRoleRequest {
    1: required domain.RoleID role_id
    /** Если не указан, роль действует на всю организацию. */
    2: optional domain.RoleScope scope
}

struct CreateInvitationRequest {
    1: required string email
    /**
     * Роли, которые получит приглашённый при вступлении. Пустой список допустим:
     * вступивший станет участником без ролей, как и при AddMember без последующего назначения.
     */
    2: required list<domain.RoleAssignment> roles
    3: optional domain.JsonObject metadata
}

struct ListInvitationsRequest {
    /** Если не указан, возвращаются приглашения всех статусов. */
    1: optional domain.InvitationStatus status
    2: optional i32 limit
    3: optional domain.ContinuationToken continuation_token
}

struct ListInvitationsResult {
    1: required list<domain.Invitation> invitations
    2: optional domain.ContinuationToken continuation_token
}

struct RevokeInvitationRequest {
    1: required string reason
}

/** Административный API управления организациями. */
service AdminManagement {

    /** Создать организацию. party_id уникален среди организаций. */
    domain.Organization CreateOrganization(1: CreateOrganizationRequest request) throws (
        1: PartyAlreadyBound ex1,
        2: InvalidRequest ex2
    )

    domain.Organization GetOrganization(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1
    )

    /** Получить организацию по идентификатору party; party_id уникален. */
    domain.Organization GetOrganizationByParty(1: domain.PartyID party_id) throws (
        1: OrganizationNotFound ex1
    )

    /** Получить страницу организаций. */
    ListOrganizationsResult ListOrganizations(1: ListOrganizationsRequest request)

    /** Изменить имя и/или метаданные организации. */
    domain.Organization ModifyOrganization(
        1: domain.OrganizationID organization_id,
        2: ModifyOrganizationRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvalidRequest ex2
    )

    /**
     * Отключить организацию без удаления данных. Деактивированная организация исключается
     * из контекста её участников, но остаётся доступной для административных операций.
     */
    domain.Organization DeactivateOrganization(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1,
        2: InvalidOrganizationState ex2
    )

    domain.Organization ActivateOrganization(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1,
        2: InvalidOrganizationState ex2
    )

    /** Получить страницу пользователей. */
    ListUsersResult ListUsers(1: ListUsersRequest request)

    /** Получить пользователя по идентификатору. */
    domain.User GetUser(1: domain.UserID user_id) throws (
        1: UnknownUser ex1
    )

    domain.Member GetMember(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2
    )

    /** Получить страницу участников организации, включая участников без ролей. */
    ListMembersResult ListMembers(
        1: domain.OrganizationID organization_id,
        2: ListMembersRequest request
    ) throws (
        1: OrganizationNotFound ex1
    )

    /**
     * Добавить пользователя в организацию; роли назначаются отдельно, через AssignMemberRole.
     * Повторный вызов для уже состоящего участника не создаёт дубль, а обновляет email.
     */
    domain.Member AddMember(
        1: domain.OrganizationID organization_id,
        2: AddMemberRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvalidRequest ex2
    )

    void RemoveMember(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2
    )

    /** Назначить роль участнику.  */
    domain.MemberRole AssignMemberRole(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id,
        3: AssignMemberRoleRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2,
        3: InvalidRequest ex3
    )

    /**
     * Снять роль с участника. Снятие последней роли разрешено: участник остаётся
     * в организации без ролей. Убрать пользователя из организации можно только через RemoveMember.
     */
    void RemoveMemberRole(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id,
        3: domain.MemberRoleID member_role_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2,
        3: MemberRoleNotFound ex3
    )

    /**
     * Создать приглашение и отправить письмо на указанный email.
     * Метод не идемпотентен: повторный вызов создаёт новое приглашение и новое письмо.
     */
    domain.Invitation CreateInvitation(
        1: domain.OrganizationID organization_id,
        2: CreateInvitationRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvalidRequest ex2
    )

    domain.Invitation GetInvitation(
        1: domain.OrganizationID organization_id,
        2: domain.InvitationID invitation_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvitationNotFound ex2
    )

    ListInvitationsResult ListInvitations(
        1: domain.OrganizationID organization_id,
        2: ListInvitationsRequest request
    ) throws (
        1: OrganizationNotFound ex1
    )

    /** Отозвать можно только приглашение в статусе pending. */
    void RevokeInvitation(
        1: domain.OrganizationID organization_id,
        2: domain.InvitationID invitation_id,
        3: RevokeInvitationRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvitationNotFound ex2,
        3: InvalidInvitationState ex3
    )
}
