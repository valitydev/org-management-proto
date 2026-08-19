<!-- markdownlint-configure-file {"MD013":{"tables":false}} -->
<!-- markdownlint-disable MD043 -->

# org-management-proto

Thrift-контракты сервиса управления организациями.

## Контракты

- [`AdminManagement`](proto/admin_management.thrift) — управление организациями,
  участниками, ролями и приглашениями.
- [`AuthContextProvider`](proto/auth_context_provider.thrift) — получение
  пользовательского контекста для авторизации в bouncer.
- Общие модели находятся в [`domain.thrift`](proto/domain.thrift).

## AdminManagement

### Организации

| Метод                    | Вход                                        | Ответ                                        | Бизнес-смысл                                                |
|--------------------------|---------------------------------------------|----------------------------------------------|-------------------------------------------------------------|
| `CreateOrganization`     | `party_id`, `owner_id`, `name`, `metadata?` | `Organization`                               | Создать организацию для party и закрепить за ней владельца. |
| `GetOrganization`        | `organization_id`                           | `Organization`                               | Получить актуальные данные организации.                     |
| `ListOrganizations`      | `limit?`, `continuation_token?`, `status?`  | список `Organization`, `continuation_token?` | Получить все организации.                                   |
| `RenameOrganization`     | `organization_id`, `name`                   | `Organization`                               | Изменить название организации.                              |
| `DeactivateOrganization` | `organization_id`                           | `Organization`                               | Отключить организацию без удаления её данных.               |
| `ActivateOrganization`   | `organization_id`                           | `Organization`                               | Вернуть деактивированную организацию в работу.              |

`Organization` содержит идентификатор организации, связанные `party_id` и
`owner_id`, название, дату создания, статус (`active` или `deactivated`) и
опциональные JSON-метаданные.

### Участники и роли

| Метод                   | Вход                                              | Ответ                     | Бизнес-смысл                                                                                 |
|-------------------------|---------------------------------------------------|---------------------------|----------------------------------------------------------------------------------------------|
| `GetMember`             | `organization_id`, `user_id`                      | `Member`                  | Получить участника вместе с назначенными ему ролями.                                         |
| `ListMembers`           | `organization_id`                                 | список `Member`           | Получить всех участников организации и их роли.                                              |
| `AddMember`             | `organization_id`, `user_id`, `email?`            | `Member`                  | Добавить пользователя в организацию. Права при этом не выдаются — роли назначаются отдельно. |
| `RemoveMember`          | `organization_id`, `user_id`                      | без данных                | Исключить пользователя из организации.                                                       |
| `AssignMemberRole`      | `organization_id`, `user_id`, `role_id`, `scope?` | `MemberRole`              | Выдать участнику роль во всей организации или в указанной области.                           |
| `RemoveMemberRole`      | `organization_id`, `user_id`, `member_role_id`    | без данных                | Снять конкретное назначение роли.                                                            |
| `GetOrganizationRole`   | `organization_id`, `role_id`                      | `OrganizationRole`        | Получить роль, доступную для назначения в организации.                                       |
| `ListOrganizationRoles` | `organization_id`                                 | список `OrganizationRole` | Получить все роли, которые можно назначать участникам организации.                           |

`Member` содержит `id` пользователя, email и список назначений ролей. Каждое
назначение `MemberRole` имеет собственный `id`, идентификатор роли и
опциональный `scope`.

Без `scope` роль действует на всю организацию. Если права нужно ограничить,
`scope_id` задаёт тип области (например, `Shop`), а `resource_id` — конкретный
ресурс. `OrganizationRole.scope_ids` показывает, в каких областях роль можно
назначать.

### Приглашения

| Метод              | Вход                                                                  | Ответ               | Бизнес-смысл                                                                     |
|--------------------|-----------------------------------------------------------------------|---------------------|----------------------------------------------------------------------------------|
| `CreateInvitation` | `organization_id`, `email`, `roles: [{role_id, scope?}]`, `metadata?` | `Invitation`        | Создать приглашение и отправить письмо.                                          |
| `GetInvitation`    | `organization_id`, `invitation_id`                                    | `Invitation`        | Получить текущее состояние приглашения.                                          |
| `ListInvitations`  | `organization_id`, `status?`                                          | список `Invitation` | Получить состояние приглашения организации с возможностью фильтрации по статусу. |
| `RevokeInvitation` | `organization_id`, `invitation_id`, `reason`                          | без данных          | Отозвать приглашение.                                                            |

Принятие приглашения выполняется пользовательским API и не входит в
`AdminManagement`.

`Invitation` содержит получателя, назначаемые роли, срок действия и статус:
`pending`, `accepted`, `expired` или `revoked`. После принятия в нём появляются
дата принятия и идентификатор участника; после отзыва — дата и причина отзыва.

## AuthContextProvider

| Метод            | Вход      | Ответ             | Бизнес-смысл                                                                                                      |
|------------------|-----------|-------------------|-------------------------------------------------------------------------------------------------------------------|
| `GetUserContext` | `user_id` | `ContextFragment` | Собрать данные пользователя, его организаций и ролей в контекст, по которому bouncer принимает решение о доступе. |
