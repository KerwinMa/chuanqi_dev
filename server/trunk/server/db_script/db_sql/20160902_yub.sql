ALTER TABLE `player_base` ADD COLUMN `legion_id` bigint(19)  NOT NULL DEFAULT 0 COMMENT '军团id' AFTER `guild_id`;