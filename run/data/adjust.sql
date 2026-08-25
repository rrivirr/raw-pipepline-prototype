
### create more test data
insert into meter (serial_number, rate, length, measured_at) select 'flow_002', rate, length, measured_at - INTERVAL '54 hours' from meter where serial_number = 'flow_0001';
update meter set rate = rate - 0.002 where serial_number = 'flow_002';


insert into meter (serial_number, rate, length, measured_at) select 'flow_004', rate + .0002, length, measured_at - INTERVAL '14 days' from meter where serial_number = 'flow_0001';

