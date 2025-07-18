CREATE database if NOT EXISTS `datalinkx` default character set utf8mb4 collate utf8mb4_unicode_ci;
use `datalinkx`;

SET NAMES utf8mb4;

CREATE TABLE `DS` (
                      `id` int unsigned NOT NULL AUTO_INCREMENT,
                      `ds_id` char(35) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'ds_[32位uuid]',
                      `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
                      `type` int DEFAULT NULL COMMENT '1MYSQL|2ORACLE|3SQLSERVER|4OPEN_DS',
                      `host` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
                      `port` int DEFAULT NULL,
                      `username` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
                      `password` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
                      `database` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
                      `schema` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT '数据库的原始schema',
                      `config` text CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT '附加配置',
                      `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '最后一次同步状态，状态代码用统一的状态代码',
                      `ctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      `utime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      `is_del` int DEFAULT '0',
                      PRIMARY KEY (`id`) USING BTREE,
                      KEY `ds_id` (`ds_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='数据库信息';


CREATE TABLE `JOB` (
                       `id` int unsigned NOT NULL AUTO_INCREMENT,
                       `job_id` char(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
                       `reader_ds_id` char(40) NOT NULL DEFAULT '' COMMENT '来源数据源id',
                       `writer_ds_id` char(40) NOT NULL DEFAULT '' COMMENT '目标数据源id',
                       `config` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
                       `crontab` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
                       `from_tb` char(40) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '来源数据表id',
                       `to_tb` char(40) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '目标数据表id',
                       `count` text CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT '导出数据统计',
                       `xxl_id` char(40) NOT NULL DEFAULT '' COMMENT 'xxl_job_id',
                       `task_id` char(40) NOT NULL DEFAULT '' COMMENT 'flink_job_id',
                       `sync_mode` longtext COMMENT 'mode: overwrite(全量)/increment(增量)，increate_field(增量字段)，increate_value(增量值)',
                       `is_del` int NOT NULL DEFAULT '0',
                       `ctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       `utime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       `status` int NOT NULL DEFAULT '0' COMMENT '0:CREATE|1:SYNCING|2:SYNC_FINISH|3:SYNC_ERROR|4:QUEUING',
                       `error_msg` longtext CHARACTER SET utf8 COLLATE utf8_general_ci,
                       PRIMARY KEY (`id`) USING BTREE,
                       KEY `job_id` (`job_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='流转任务配置信息';

CREATE TABLE `JOB_RELATION` (
                                `id` int unsigned NOT NULL AUTO_INCREMENT,
                                `relation_id` char(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '依赖关系id',
                                `job_id` char(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '流转任务id',
                                `sub_job_id` char(40) NOT NULL DEFAULT '' COMMENT '流转任务子id',
                                `priority` int COMMENT '同级任务优先级，越高优先级越高',
                                `is_del` int NOT NULL DEFAULT '0',
                                `ctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                `utime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`id`) USING BTREE,
                                KEY `job_id` (`job_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='流转任务级联配置表';

DROP TABLE IF EXISTS `job_log`;
CREATE TABLE `job_log` (
                           `id` int unsigned NOT NULL AUTO_INCREMENT,
                           `is_del` int DEFAULT NULL,
                           `cost_time` int unsigned NOT NULL,
                           `count` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
                           `end_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           `error_msg` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
                           `job_id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
                           `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '任务启动时间',
                           `status` tinyint unsigned DEFAULT NULL COMMENT '1-失败；0-成功',
                           `error_analysis` longtext,
                           PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT COMMENT='流转任务日志';


-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
                               `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
                               `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '参数名称',
                               `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '参数键名',
                               `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '参数键值',
                               `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
                               `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '创建者',
                               `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
                               `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '更新者',
                               `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
                               `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL COMMENT '备注',
                               PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_as_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2025-01-07 09:47:24', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2025-01-07 09:47:24', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2025-01-07 09:47:24', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2025-01-07 09:47:24', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2025-01-07 09:47:24', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2025-01-07 09:47:24', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
                             `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
                             `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NOT NULL COMMENT '菜单名称',
                             `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
                             `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
                             `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '路由地址',
                             `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL COMMENT '组件路径',
                             `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL COMMENT '路由参数',
                             `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '路由名称',
                             `is_frame` int NULL DEFAULT 0 COMMENT '是否为外链（0是 1否）',
                             `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
                             `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
                             `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
                             `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用 ）',
                             `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL COMMENT '权限标识',
                             `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '#' COMMENT '菜单图标',
                             `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '创建者',
                             `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
                             `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '更新者',
                             `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
                             `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '备注',
                             PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2011 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_as_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1, 'menu.home', 0, 1, '/', 'BasicLayout', NULL, 'index', 1, 0, 'M', '0', '0', 'index', '#', NULL, NULL, 'admin', '2025-03-14 10:35:00', NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (2, 'menu.dashboard', 1, 1, '/dashboard', 'dashboard', NULL, 'dashboard', 0, 0, 'M', '0', '0', 'dashboard', 'bxAnaalyse', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (3, 'menu.datasource', 1, 2, '/datasource', 'RouteView', NULL, 'datasource', 1, 0, 'M', '0', '0', 'datasource', 'dataManage', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (4, 'menu.transferTask', 1, 3, '/transferTask', 'RouteView', NULL, 'transferTask', 1, 0, 'M', '0', '0', 'transferTask', 'task', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (5, 'menu.streamingTransferTask', 1, 4, '/streaming/transferTask', 'RouteView', NULL, 'streamingTransferTask', 1, 0, 'M', '0', '0', 'streamingTransferTask', 'task', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (6, 'menu.computeTransferTask', 1, 5, '/compute/transferTask', 'RouteView', NULL, 'computeTransferTask', 1, 0, 'M', '0', '0', 'computeTransferTask', 'task', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (7, 'menu.taskrelationlist', 1, 6, '/job_relation', 'jobrelation/JobRelationList', NULL, 'jobRelation', 1, 1, 'C', '0', '0', 'jobRelation', 'taskLog', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (8, 'menu.taskrelationmap', 1, 7, '/job_relation_map', 'jobrelation/JobRelationBloodMap', NULL, 'jobMap', 1, 1, 'C', '0', '0', 'jobMap', 'taskLog', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (9, 'menu.tasklistlog', 1, 8, '/job_log', 'joblog/JobLogList', NULL, 'jobLog', 1, 1, 'C', '0', '0', 'jobLog', 'taskLog', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (10, 'menu.account.center', 1, 9, '/account/center', 'account/center', NULL, 'AccountCenter', 1, 1, 'M', '1', '0', 'AccountCenter', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (11, 'menu.account.settings', 1, 10, '/account/settings', 'account/settings', NULL, 'AccountSettings', 1, 1, 'M', '1', '0', 'AccountSettings', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (12, 'menu.system.management', 1, 11, '/systemManager', 'RouteView', NULL, 'systemManager', 1, 1, 'M', '0', '0', 'systemManager', 'systemManagement', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (13, 'VisualAnalysis', 1, 12, '/visualization', 'visualization', NULL, 'visualization', 0, 0, 'M', '0', '0', 'visualization', 'visualAnalysis', NULL, NULL, 'admin', '2025-03-14 10:35:00', NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (14, '智能助手', 1, 13, '/intelligentAssistant', 'deepseek', NULL, 'intelligentAssistant', 0, 0, 'M', '0', '0', 'intelligentAssistant', 'deepSeek', NULL, NULL, 'admin', '2025-04-19 14:12:29', NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (15, 'menu.datasourceList', 3, 1, '/datalist', 'datasource/DsList', NULL, 'datalist', 1, 1, 'C', '0', '0', 'datalist', 'dataList', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (16, 'menu.taskList', 4, 1, '/job', 'job/JobList', NULL, 'job', 1, 1, 'C', '0', '0', 'job', 'taskList', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (17, 'menu.streamingTaskList', 5, 1, '/streaming/job', 'job/JobListOfStreaming', NULL, 'StreamingJob', 1, 1, 'C', '0', '0', 'StreamingJob', 'taskList', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (18, 'menu.computeTaskList', 6, 1, '/compute/job', 'job/JobListOfCompute', NULL, 'ComputeJob', 1, 1, 'C', '0', '0', 'ComputeJob', 'taskList', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (19, 'menu.systemMonitor', 12, 1, '/system/monitor', 'system/systemMonitor', NULL, 'systemMonitor', 1, 0, 'C', '0', '0', 'systemMonitor', 'task', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (20, 'menu.systemMenu', 12, 2, '/system/menu', 'system/systemMenu', NULL, 'systemMenu', 1, 0, 'C', '0', '0', 'systemMenu', 'menuManagement', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (21, 'menu.role.management', 12, 3, '/system/role', 'system/systemRole', NULL, 'systemRole', 0, 0, 'C', '0', '0', 'systemRole', 'roleManagement', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (22, 'account.settings.menuMap.basic', 11, 1, '/account/settings/basic', 'account/settings/BasicSetting', NULL, 'BasicSetting', 1, 1, 'C', '1', '0', 'BasicSetting', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (23, 'account.settings.menuMap.security', 11, 2, '/account/settings/security', 'account/settings/Security', NULL, 'SecuritySettings', 1, 1, 'C', '1', '0', 'SecuritySettings', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (24, 'account.settings.menuMap.custom', 11, 3, '/account/settings/custom', 'account/settings/Custom', NULL, 'CustomSettings', 1, 1, 'C', '1', '0', 'CustomSettings', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (25, 'account.settings.menuMap.binding', 11, 4, '/account/settings/binding', 'account/settings/Binding', NULL, 'BindingSettings', 1, 1, 'C', '1', '0', 'BindingSettings', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (26, 'account.settings.menuMap.notification', 11, 5, '/account/settings/notification', 'account/settings/Notification', NULL, 'NotificationSettings', 1, 1, 'C', '1', '0', 'NotificationSettings', '#', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (27, 'HistoryChart', 1, 14, '/visualization/HistoryChart', 'visualization/HistoryChart', NULL, 'HistoryChart', 0, 0, 'C', '0', '0', 'HistoryChart', 'historicalPictures', '', NULL, 'admin', '2025-04-15 03:22:47', '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
                             `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
                             `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NOT NULL COMMENT '角色名称',
                             `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NOT NULL COMMENT '角色权限字符串',
                             `role_sort` int NOT NULL COMMENT '显示顺序',
                             `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
                             `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
                             `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
                             `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NOT NULL DEFAULT '0' COMMENT '角色状态（0正常 1停用）',
                             `is_del` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
                             `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '创建者',
                             `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
                             `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '更新者',
                             `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
                             `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL COMMENT '备注',
                             PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 106 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_as_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2025-01-08 11:34:41', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2025-01-08 11:34:41', '', NULL, '普通角色');

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
                                  `role_id` bigint NOT NULL COMMENT '角色ID',
                                  `menu_id` bigint NOT NULL COMMENT '菜单ID',
                                  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_as_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 1);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 2);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 3);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 4);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 5);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 6);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 7);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 8);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 9);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 10);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 11);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 12);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 13);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 14);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 15);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 16);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 17);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 18);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 19);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 20);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 21);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 22);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 23);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 24);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 25);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 26);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 27);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 1);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 2);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 3);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 4);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 5);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 6);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 7);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 8);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 9);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 10);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 11);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 12);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 13);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 14);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 15);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 16);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 17);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 18);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 19);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 20);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 21);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 22);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 23);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 24);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 25);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 26);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (2, 27);


-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
                             `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
                             `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
                             `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NOT NULL COMMENT '用户账号',
                             `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NOT NULL COMMENT '用户昵称',
                             `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
                             `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '用户邮箱',
                             `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '手机号码',
                             `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
                             `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '头像地址',
                             `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '密码',
                             `password_level` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL,
                             `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
                             `is_del` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
                             `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '最后登录IP',
                             `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
                             `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '创建者',
                             `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
                             `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT '' COMMENT '更新者',
                             `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
                             `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci NULL DEFAULT NULL COMMENT '个人介绍',
                             PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 111 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_as_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '管理员', '00', '123456@qq.com', '15888888888', '1', NULL, '$2a$10$3wC82lCJDXcG8E3ETiQcoes/gmO4ENUDeT5JVrk.eLY02SQrGi5Xe', '1', '0', '0', '127.0.0.1', '2025-01-07 13:40:30', 'admin', '2025-01-07 13:40:30', '', NULL, NULL);
INSERT INTO `sys_user` VALUES (2, 105, 'user', '普通用户', '00', '123456@qq.com', '15666666666', '1', NULL, '$2a$10$3wC82lCJDXcG8E3ETiQcoes/gmO4ENUDeT5JVrk.eLY02SQrGi5Xe', '2', '0', '0', '127.0.0.1', '2025-01-08 10:34:24', 'admin', '2025-01-08 10:34:24', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
                                  `user_id` bigint NOT NULL COMMENT '用户ID',
                                  `role_id` bigint NOT NULL COMMENT '角色ID',
                                  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_as_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);

-- ----------------------------
-- Table structure for images
-- ----------------------------
DROP TABLE IF EXISTS `images`;
CREATE TABLE `images`  (
                           `id` int NOT NULL AUTO_INCREMENT,
                           `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                           `data` mediumblob NULL,
                           `is_del` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0',
                           PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `deepseek_conversation`;
CREATE TABLE `deepseek_conversation` (
                                         `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                                         `is_del` int DEFAULT '0',
                                         `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                                         `user_id` bigint DEFAULT NULL,
                                         `created_time` datetime(6) DEFAULT NULL,
                                         PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='deepseek对话记录表';

DROP TABLE IF EXISTS `deepseek_message`;
CREATE TABLE `deepseek_message` (
                                    `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                                    `completion_tokens` int DEFAULT '0' COMMENT '模型 completion 产生的 token 数',
                                    `content` text COLLATE utf8mb4_unicode_ci COMMENT '内容',
                                    `conversation_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                                    `is_del` int DEFAULT '0',
                                    `model` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '模型名称',
                                    `prompt_cache_hit_tokens` int DEFAULT '0' COMMENT '用户 prompt 中，命中上下文缓存的 token 数',
                                    `prompt_cache_miss_tokens` int DEFAULT '0' COMMENT '用户 prompt 中，未命中上下文缓存的 token 数',
                                    `prompt_tokens` int DEFAULT '0' COMMENT '用户 prompt 所包含的 token 数',
                                    `reasoning_content` text COLLATE utf8mb4_unicode_ci COMMENT '推理模型所产生的思维链',
                                    `reasoning_tokens` int DEFAULT '0' COMMENT '推理模型所产生的思维链 token 数量',
                                    `role` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                                    `total_tokens` int DEFAULT '0' COMMENT '该请求中，所有 token 的数量（prompt + completion）',
                                    `created_time` datetime(6) DEFAULT NULL,
                                    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='deepseek消息记录表';

DROP TABLE IF EXISTS `user_chart_images`;
CREATE TABLE `user_chart_images` (
                                     `id` int NOT NULL AUTO_INCREMENT,
                                     `user_id` int NOT NULL,
                                     `image` mediumblob NOT NULL,
                                     `description` varchar(255) DEFAULT NULL,
                                     `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                     `is_del` int DEFAULT '0' COMMENT '是否删除',
                                     `chart_config` json DEFAULT NULL COMMENT '图表配置',
                                     `type` int DEFAULT '0' COMMENT '0 系统生成 1 用户上传',
                                     `updated_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                     `chart_json_data` json DEFAULT NULL COMMENT '图表数据',
                                     `chart_styles` json DEFAULT NULL COMMENT '图表样式',
                                     PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户图表图片表';

alter table JOB ADD COLUMN  `name` varchar(64) DEFAULT NULL COMMENT '任务名称';;

alter table JOB ADD COLUMN `cover` tinyint NOT NULL DEFAULT '0' COMMENT '是否开启覆盖';

-- 流式任务表结构变更

alter table JOB ADD COLUMN `type` tinyint NOT NULL DEFAULT '0' COMMENT '是否是流式任务';

alter table JOB ADD COLUMN `checkpoint` longtext CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT '流式任务端点续传';

alter table JOB ADD COLUMN `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;

alter table JOB ADD COLUMN `retry_time` int NOT NULL DEFAULT '0' COMMENT '流式任务重试次数';

alter table JOB ADD COLUMN `graph` longtext CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT '计算画布';
