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

/** В организации уже есть организация с указанным party_id. */
exception PartyAlreadyBound {}

/** Операцию нельзя выполнить для текущего состояния организации. */
exception InvalidOrganizationState {
    1: required string reason
}

struct CreateOrganizationRequest {
    /** Идентификатор party, для которого создаётся организация. */
    1: required domain.PartyID party_id
    /** Идентификатор владельца организации. */
    2: required domain.UserID owner_id
    3: required string name
    /** JSON-метаданные организации. */
    4: optional string metadata
}

struct ListOrganizationsRequest {
    1: optional i32 limit
    2: optional domain.ContinuationToken continuation_token
    /** Если не указан, возвращаются организации всех статусов. */
    3: optional domain.OrganizationStatus status
}

struct ListOrganizationsResult {
    1: required list<domain.Organization> organizations
    2: optional domain.ContinuationToken continuation_token
}

struct AddMemberRequest {
    1: required domain.UserID user_id
    /** Email пользователя. */
    2: optional string email
}

struct AssignMemberRoleRequest {
    1: required domain.RoleID role_id
    /** Если не указан, роль действует на всю организацию. */
    2: optional domain.RoleScope scope
}

struct CreateInvitationRequest {
    1: required string email
    2: required list<domain.RoleAssignment> roles
    /** JSON-метаданные приглашения. */
    3: optional string metadata
}

struct ListInvitationsRequest {
    /** Если не указан, возвращаются приглашения всех статусов. */
    1: optional domain.InvitationStatus status
}

struct RevokeInvitationRequest {
    1: required string reason
}

/** Административный API управления организациями. */
service AdminManagement {

    /** Создать организацию. party_id уникален среди организаций. */
    domain.Organization CreateOrganization(1: CreateOrganizationRequest request) throws (
        1: PartyAlreadyBound ex1
    )

    domain.Organization GetOrganization(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1
    )

    /** Получить страницу организаций. */
    ListOrganizationsResult ListOrganizations(1: ListOrganizationsRequest request)

    domain.Organization RenameOrganization(
        1: domain.OrganizationID organization_id,
        2: string name
    ) throws (
        1: OrganizationNotFound ex1
    )

    /** Отключить организацию без удаления данных */
    domain.Organization DeactivateOrganization(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1,
        2: InvalidOrganizationState ex2
    )

    domain.Organization ActivateOrganization(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1,
        2: InvalidOrganizationState ex2
    )

    domain.Member GetMember(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2
    )

    list<domain.Member> ListMembers(1: domain.OrganizationID organization_id) throws (
        1: OrganizationNotFound ex1
    )

    /** Добавить пользователя в организацию без назначения роли. */
    domain.Member AddMember(
        1: domain.OrganizationID organization_id,
        2: AddMemberRequest request
    ) throws (
        1: OrganizationNotFound ex1
    )

    void RemoveMember(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2
    )

    /** Назначить роль участнику. */
    domain.MemberRole AssignMemberRole(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id,
        3: AssignMemberRoleRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2
    )

    void RemoveMemberRole(
        1: domain.OrganizationID organization_id,
        2: domain.UserID user_id,
        3: domain.MemberRoleID member_role_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: MemberNotFound ex2,
        3: MemberRoleNotFound ex3
    )

    domain.OrganizationRole GetOrganizationRole(
        1: domain.OrganizationID organization_id,
        2: domain.RoleID role_id
    ) throws (
        1: OrganizationNotFound ex1
    )

    list<domain.OrganizationRole> ListOrganizationRoles(
        1: domain.OrganizationID organization_id
    ) throws (
        1: OrganizationNotFound ex1
    )

    /** Создать приглашение и отправить письмо на указанный email. */
    domain.Invitation CreateInvitation(
        1: domain.OrganizationID organization_id,
        2: CreateInvitationRequest request
    ) throws (
        1: OrganizationNotFound ex1
    )

    domain.Invitation GetInvitation(
        1: domain.OrganizationID organization_id,
        2: domain.InvitationID invitation_id
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvitationNotFound ex2
    )

    list<domain.Invitation> ListInvitations(
        1: domain.OrganizationID organization_id,
        2: ListInvitationsRequest request
    ) throws (
        1: OrganizationNotFound ex1
    )

    void RevokeInvitation(
        1: domain.OrganizationID organization_id,
        2: domain.InvitationID invitation_id,
        3: RevokeInvitationRequest request
    ) throws (
        1: OrganizationNotFound ex1,
        2: InvitationNotFound ex2,
        3: InvalidOrganizationState ex3
    )
}
