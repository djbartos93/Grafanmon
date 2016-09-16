require 'snmp'
require 'influxdb'


def influx(value, statusname, measurename)
  #lets define some stuff about our database, possibly will be converted into a config file later on
  #username = 'graf' #FUTURE
  #password = 'graffing' #FUTURE
  database = "home"
  #name = valuename
  host = "172.16.0.34"

  influxdb = InfluxDB::Client.new  database: database, host: host
  name = measurename
  data = {
    values: { value: value },
    tags:   { stat: statusname } # tags are optional
  }

  influxdb.write_point(name, data)
  puts data
  #puts dataout
end

def influxresult(value, statusname, measurename)
  #lets define some stuff about our database, possibly will be converted into a config file later on
  #username = 'graf' #FUTURE
  #password = 'graffing' #FUTURE
  database = "home"
  #name = valuename
  host = "172.16.0.34"

  influxdb = InfluxDB::Client.new  database: database, host: host
  name = measurename
  data = {
    values: { result: value },
    tags:   { test: statusname } # tags are optional
  }

  influxdb.write_point(name, data)
  puts data
  #puts dataout
end


def upsruntime(host, name)
  SNMP::Manager.open(:host => host) do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.2.2.3.0"])
      response.each_varbind do |vb|
          puts "#{vb.value.to_s}"
          influxresult(vb.value.to_s, "runtime", name)
        end
    end
end


def upsinvoltage(host, name)
  SNMP::Manager.open(:host => '172.16.0.59') do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.3.2.1.0"])
      response.each_varbind do |vb|
          puts "#{vb.value.to_s}"
          influx(vb.value.to_i, "linevolt", name)
        end
    end
end


def upsoutvoltage(host, name)
  SNMP::Manager.open(:host => host) do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.4.2.1.0"])
      response.each_varbind do |vb|
          puts "#{vb.value.to_s}"
          influx(vb.value.to_i, "outvolt", name)
        end
    end
end


def upsload(host, name)
  SNMP::Manager.open(:host => host) do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.4.2.3.0"])
      response.each_varbind do |vb|
          puts "#{vb.value.to_s}"
          influx(vb.value.to_i, "load", name)
        end
    end
end


def upscurrent(host, name)
  SNMP::Manager.open(:host => host) do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.4.2.4.0"])
      response.each_varbind do |vb|
          puts "#{vb.value.to_s}"
          influx(vb.value.to_i, "current", name)
        end
    end
end


def upslasttestresult(host, name)
  SNMP::Manager.open(:host => '172.16.0.59') do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.7.2.3.0"])
      response.each_varbind do |vb|
          input = "#{vb.value.to_i}"
          if input == "1"
            output = "Pass"
          else
            output = "FAIL!"
          end
          influxresult(output, "test-result", name)
        end
    end
end


def upslasttestdate(host, name)
  SNMP::Manager.open(:host => host) do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.7.2.4.0"])
      response.each_varbind do |vb|
          puts "#{vb.value.to_s}"
          influxresult("#{vb.value.to_s}", "test-date", name)
        end
    end
end


def upstemp(host, name)
  SNMP::Manager.open(:host => host) do |manager|
      response = manager.get(["1.3.6.1.4.1.318.1.1.1.2.2.2.0"])
      response.each_varbind do |vb|
          puts "#{vb.value}".to_i
          returns = vb.value.to_i
          influx(returns, "tempc", name)
        end
    end
end


def measure
  loop do
    upsruntime("172.16.0.59" , "UPS-1")
    upsinvoltage("172.16.0.59" , "UPS-1")
    upsoutvoltage("172.16.0.59" , "UPS-1")
    upsload("172.16.0.59" , "UPS-1")
    upscurrent("172.16.0.59" , "UPS-1")
    upslasttestresult("172.16.0.59", "UPS-1")
    upslasttestdate("172.16.0.59", "UPS-1")
    upstemp("172.16.0.59" , "UPS-1")


    upsruntime("172.16.0.60" , "UPS-2")
    upsinvoltage("172.16.0.60" , "UPS-2")
    upsoutvoltage("172.16.0.60" , "UPS-2")
    upsload("172.16.0.60" , "UPS-2")
    upscurrent("172.16.0.60" , "UPS-2")
    upslasttestresult("172.16.0.60", "UPS-2")
    upslasttestdate("172.16.0.60", "UPS-2")
    upstemp("172.16.0.59" , "UPS-2")
    sleep 30
  end
end

measure
