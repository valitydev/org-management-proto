namespace java dev.vality.orgmanagement
namespace erlang orgmgmt.domain
namespace elixir OrgManagement.Domain

typedef string UserID
typedef string OrganizationID
typedef string PartyID
typedef string RoleID
typedef string MemberRoleID
typedef string InvitationID
typedef string ContinuationToken

/**
 * Организация доступна для работы либо деактивирована с сохранением истории.
 */
enum OrganizationStatus {
    active = 1,
    deactivated = 2
}

/**
 * Область действия роли. При отсутствии scope роль действует на всю организацию.
 * scope_id соответствует идентификатору типа области, например "Shop".
 */
struct RoleScope {
    1: required string scope_id
    2: optional string resource_id
}

/** Назначение роли конкретному участнику организации. */
struct MemberRole {
    1: required MemberRoleID id
    2: required RoleID role_id
    3: optional RoleScope scope
}

/** Роль без идентификатора назначения; используется при создании приглашения. */
struct RoleAssignment {
    1: required RoleID role_id
    2: optional RoleScope scope
}

/** Участник организации с его действующими назначениями ролей. */
struct Member {
    1: required UserID id
    2: optional string email
    3: required list<MemberRole> roles
}

/** Роль, доступная в организации для назначения её участникам. */
struct OrganizationRole {
    1: required RoleID id
    2: required string name
    3: required list<string> scope_ids
}

enum InvitationStatus {
    pending = 1,
    accepted = 2,
    expired = 3,
    revoked = 4
}

/** Приглашение пользователя в организацию по email. */
struct Invitation {
    1: required InvitationID id
    2: required OrganizationID organization_id
    3: required string created_at
    4: required string expires_at
    5: required string email
    6: required list<RoleAssignment> roles
    7: required InvitationStatus status
    8: optional string metadata
    9: optional string accepted_at
    10: optional UserID accepted_member_id
    11: optional string revoked_at
    12: optional string revocation_reason
}

/**
 * Административное представление организации.
 * metadata хранится в формате JSON.
 */
struct Organization {
    1: required OrganizationID id
    2: required PartyID party_id
    3: required UserID owner_id
    4: required string name
    5: required string created_at
    6: required OrganizationStatus status
    7: optional string metadata
}
