!H2!SET IGNORECASE TRUE;
create memory table T_AUTHENTICATION_TOKEN ( AUT_ID_C varchar(36) not null, AUT_IDUSER_C varchar(36) not null, AUT_LONGLASTED_B bit not null, AUT_CREATIONDATE_D datetime not null, AUT_LASTCONNECTIONDATE_D datetime, AUT_IP_C varchar(45), AUT_UA_C varchar(1000), primary key (AUT_ID_C) );
create memory table T_BASE_FUNCTION ( BAF_ID_C varchar(20) not null, primary key (BAF_ID_C) );
create cached table T_FILE ( FIL_ID_C varchar(36) not null, FIL_IDDOC_C varchar(36), FIL_IDUSER_C varchar(36) not null, FIL_MIMETYPE_C varchar(100) not null, FIL_CREATEDATE_D datetime, FIL_DELETEDATE_D datetime, FIL_ORDER_N int, FIL_CONTENT_C longvarchar, primary key (FIL_ID_C) );
create memory table T_CONFIG ( CFG_ID_C varchar(50) not null, CFG_VALUE_C varchar(250) not null, primary key (CFG_ID_C) );
create memory table T_LOCALE ( LOC_ID_C varchar(10) not null, primary key (LOC_ID_C) );
create cached table T_DOCUMENT ( DOC_ID_C varchar(36) not null, DOC_IDUSER_C varchar(36) not null, DOC_TITLE_C varchar(100) not null, DOC_DESCRIPTION_C varchar(4000), DOC_CREATEDATE_D datetime, DOC_DELETEDATE_D datetime, DOC_LANGUAGE_C varchar(3) default 'fra' not null, primary key (DOC_ID_C) );
create memory table T_USER ( USE_ID_C varchar(36) not null, USE_IDLOCALE_C varchar(10) not null, USE_IDROLE_C varchar(36) not null, USE_USERNAME_C varchar(50) not null, USE_PASSWORD_C varchar(60) not null, USE_EMAIL_C varchar(100) not null, USE_THEME_C varchar(100) not null, USE_FIRSTCONNECTION_B bit not null, USE_CREATEDATE_D datetime not null, USE_DELETEDATE_D datetime, USE_PRIVATEKEY_C varchar(100) default '' not null, primary key (USE_ID_C) );
create memory table T_ROLE ( ROL_ID_C varchar(36) not null, ROL_NAME_C varchar(36) not null, ROL_CREATEDATE_D datetime not null, ROL_DELETEDATE_D datetime, primary key (ROL_ID_C) );
create memory table T_ROLE_BASE_FUNCTION ( RBF_ID_C varchar(36) not null, RBF_IDROLE_C varchar(36) not null, RBF_IDBASEFUNCTION_C varchar(20) not null, RBF_CREATEDATE_D datetime not null, RBF_DELETEDATE_D datetime, primary key (RBF_ID_C) );
create cached table T_TAG ( TAG_ID_C varchar(36) not null, TAG_IDUSER_C varchar(36) not null, TAG_NAME_C varchar(36) not null, TAG_CREATEDATE_D datetime, TAG_DELETEDATE_D datetime, TAG_COLOR_C varchar(7) default '#3a87ad' not null, primary key (TAG_ID_C) );
create cached table T_DOCUMENT_TAG ( DOT_ID_C varchar(36) not null, DOT_IDDOCUMENT_C varchar(36) not null, DOT_IDTAG_C varchar(36) not null, DOT_DELETEDATE_D datetime, primary key (DOT_ID_C) );
create cached table T_ACL ( ACL_ID_C varchar(36) not null, ACL_PERM_C varchar(30) not null, ACL_SOURCEID_C varchar(36) not null, ACL_TARGETID_C varchar(36) not null, ACL_DELETEDATE_D datetime, primary key (ACL_ID_C) );
create cached table T_SHARE ( SHA_ID_C varchar(36) not null, SHA_NAME_C varchar(36), SHA_CREATEDATE_D datetime, SHA_DELETEDATE_D datetime, primary key (SHA_ID_C) );
create cached table T_AUDIT_LOG ( LOG_ID_C varchar(36) not null, LOG_IDENTITY_C varchar(36) not null, LOG_CLASSENTITY_C varchar(50) not null, LOG_TYPE_C varchar(50) not null, LOG_MESSAGE_C varchar(1000), LOG_CREATEDATE_D datetime, primary key (LOG_ID_C) );

alter table T_AUTHENTICATION_TOKEN add constraint FK_AUT_IDUSER_C foreign key (AUT_IDUSER_C) references T_USER (USE_ID_C) on delete restrict on update restrict;
alter table T_DOCUMENT add constraint FK_DOC_IDUSER_C foreign key (DOC_IDUSER_C) references T_USER (USE_ID_C) on delete restrict on update restrict;
alter table T_FILE add constraint FK_FIL_IDDOC_C foreign key (FIL_IDDOC_C) references T_DOCUMENT (DOC_ID_C) on delete restrict on update restrict;
alter table T_FILE add constraint FK_FIL_IDUSER_C foreign key (FIL_IDUSER_C) references T_USER (USE_ID_C) on delete restrict on update restrict;
alter table T_USER add constraint FK_USE_IDLOCALE_C foreign key (USE_IDLOCALE_C) references T_LOCALE (LOC_ID_C) on delete restrict on update restrict;
alter table T_USER add constraint FK_USE_IDROLE_C foreign key (USE_IDROLE_C) references T_ROLE (ROL_ID_C) on delete restrict on update restrict;
alter table T_TAG add constraint FK_TAG_IDUSER_C foreign key (TAG_IDUSER_C) references T_USER (USE_ID_C) on delete restrict on update restrict;
alter table T_DOCUMENT_TAG add constraint FK_DOT_IDDOCUMENT_C foreign key (DOT_IDDOCUMENT_C) references T_DOCUMENT (DOC_ID_C) on delete restrict on update restrict;
alter table T_DOCUMENT_TAG add constraint FK_DOT_IDTAG_C foreign key (DOT_IDTAG_C) references T_TAG (TAG_ID_C) on delete restrict on update restrict;
alter table T_ROLE_BASE_FUNCTION add constraint FK_RBF_IDROLE_C foreign key (RBF_IDROLE_C) references T_ROLE (ROL_ID_C) on delete restrict on update restrict;
alter table T_ROLE_BASE_FUNCTION add constraint FK_RBF_IDBASEFUNCTION_C foreign key (RBF_IDBASEFUNCTION_C) references T_BASE_FUNCTION (BAF_ID_C) on delete restrict on update restrict;

create index IDX_DOC_TITLE_C on T_DOCUMENT (DOC_TITLE_C);
create index IDX_DOC_CREATEDATE_D on T_DOCUMENT (DOC_CREATEDATE_D);
create index IDX_DOC_LANGUAGE_C on T_DOCUMENT (DOC_LANGUAGE_C);
create index IDX_ACL_SOURCEID_C on T_ACL (ACL_SOURCEID_C);
create index IDX_ACL_TARGETID_C on T_ACL (ACL_TARGETID_C);
create index IDX_LOG_IDENTITY_C on T_AUDIT_LOG (LOG_IDENTITY_C);

insert into T_CONFIG(CFG_ID_C, CFG_VALUE_C) values('DB_VERSION', '0');
insert into T_CONFIG(CFG_ID_C, CFG_VALUE_C) values('LUCENE_DIRECTORY_STORAGE', 'FILE');
insert into T_BASE_FUNCTION(BAF_ID_C) values('ADMIN');
insert into T_LOCALE(LOC_ID_C) values('en');
insert into T_LOCALE(LOC_ID_C) values('fr');
insert into T_ROLE(ROL_ID_C, ROL_NAME_C, ROL_CREATEDATE_D) values('admin', 'Admin', NOW());
insert into T_ROLE(ROL_ID_C, ROL_NAME_C, ROL_CREATEDATE_D) values('user', 'User', NOW());
insert into T_ROLE_BASE_FUNCTION(RBF_ID_C, RBF_IDROLE_C, RBF_IDBASEFUNCTION_C, RBF_CREATEDATE_D) values('admin_ADMIN', 'admin', 'ADMIN', NOW());
insert into T_USER(USE_ID_C, USE_IDLOCALE_C, USE_IDROLE_C, USE_USERNAME_C, USE_PASSWORD_C, USE_EMAIL_C, USE_THEME_C, USE_FIRSTCONNECTION_B, USE_CREATEDATE_D, USE_PRIVATEKEY_C) values('admin', 'en', 'admin', 'admin', '$2y$10$xg0EEKVUehutDI1m6qQhVeFz7SMQMl1jQzjf2KkVsR2c7aV2vyyjK', 'admin@localhost', 'default.less', true, NOW(), 'AdminPk');
-- 添加注册状态字段（默认值为"PENDING"，表示待审批）
ALTER TABLE T_USER ADD COLUMN USE_REGISTRATIONSTATUS_C VARCHAR(20) DEFAULT 'PENDING';
-- 添加注册请求时间字段（默认值为当前时间）
ALTER TABLE T_USER ADD COLUMN USE_REGISTRATIONDATE_D DATETIME DEFAULT NOW();