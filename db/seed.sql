create database magicarpi;

create table `wireless_network_logs` (
    `id` int(11) not null auto_increment,
    `created` datetime default utc_timestamp(),
    `essid` text not null,
    `channel` int(11) default null,
    `signal_loss` varchar(64) default null,
    `auth` varchar(64) default null,
    `lat` varchar(64) default null,
    `lng` varchar(64) default null,
    `hdop` decimal(10,3) default null,
    `vdop` decimal(10,3) default null,
    `pdop` decimal(10,3) default null,
    primary key (`id`),
    key `idx_essid` (`essid`)
);

create table `wireless_network_dumps` (
    `id` int(11) not null auto_increment,
    `wireless_network_log_id` int(11) not null,
    `content` text not null,
    primary key (`id`)
)
