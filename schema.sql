-- FIXME damnit, is a serial bigint or integer under the hood?
create table users (
    id serial primary key,
    username varchar(20) not null,
    password varchar not null,
    realname varchar(80) not null,
    UNIQUE(username)
)
---
create table user_techs (
    id serial primary key,
    user_id integer not null,
    -- not sure it makes sense to FK to something that's going to be so variant.
    tech varchar(25) not null,
    UNIQUE(user_id, tech)
)
---
create table meetings (
    id serial primary key,
    meeting_time date not null,
    UNIQUE(meeting_time)
)
---
create table projects (
    id serial primary key,
    user_id integer not null,
    name varchar(80) not null,
    description text not null,
    UNIQUE(name)
)
---
-- "this user is interested in this project"
create table user_projects_interested (
    id serial primary key,
    user_id integer not null,
    project_id integer not null,
    meeting_id integer not null,
    UNIQUE(user_id, project_id, meeting_id)
)
---
create table project_meeting_assignment (
    id serial primary key,
    project_id integer not null,
    meeting_id integer not null,
    UNIQUE(project_id, meeting_id)
)
