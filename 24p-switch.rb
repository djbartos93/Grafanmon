require 'snmp'
require 'influxdb'
def influx(valuein, valueout, ifname, measurename)
  #lets define some stuff about our database, possibly will be converted into a config file later on
  #username = 'graf' #FUTURE
  #password = 'graffing' #FUTURE
  database = "home"
  #name = valuename
  host = "172.16.0.34"

  influxdb = InfluxDB::Client.new  database: database, host: host
  name = measurename
  datain = {
    values: { value: valuein },
    tags:   { interface: ifname, direction: "in" } # tags are optional
  }
  dataout = {
    values: { value: valueout },
    tags:   { interface: ifname, direction: "out" } # tags are optional
  }

  influxdb.write_point(name, datain)
  influxdb.write_point(name, dataout)
  puts data1
  puts data2
end

def interfaces
  ifTable_columns = ["ifIndex", "ifInOctets", "ifOutOctets"]
  SNMP::Manager.open(:host => '172.16.0.13') do |manager|
      manager.walk(ifTable_columns) do |row|
          interface, inoct, outoct, = row.map(&:value).map(&:to_i)
          row.each { |vb| influx(inoct, outoct, "#{interface}", "switch01-test") }
      end
    end
end

def measure
  loop do
    puts interfaces
    sleep 10
  end
end

measure
