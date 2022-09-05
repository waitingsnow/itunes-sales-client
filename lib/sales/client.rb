module Spaceship
  # This class is used to upload Digital files (Images, Videos, JSON files) onto the du-itc service.
  # Its implementation is tied to the tunes module (in particular using +AppVersion+ instances)
  class SalesClient < Spaceship::Client #:nodoc:
    #####################################################
    # @!group Init and Login
    #####################################################

    def self.hostname
      "https://appstoreconnect.apple.com/"
    end

    def get_data(ids, start_time = Date.today - 5.day, end_time = Date.today - 1.day)

      start_date = start_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
      start_date_prefix = start_time.strftime('%Y-%m-%d')
      end_date = end_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
      end_date_prefix = end_time.strftime('%Y-%m-%d')

      csrf_response = request(:post) do |req|
        req.url("trends/gsf/owasp/csrf-guard.js")
        req.body = ""
        req.headers['Cookie'] = cookie
        req.headers["X-Apple-Id-Session-Id"] = x_apple_id_session_id
        req.headers['FETCH-CSRF-TOKEN'] = '1'
        req.headers['Referer'] = "https://appstoreconnect.apple.com"
      end

      csrf = csrf_response.body.byteslice(5...)

      fail 'ids must be array' unless ids.is_a?(Array)

      body =
      {
          "filters":
              [
                {
                  "dimensionKey": "gross_adam_id_piano",
                  "option_keys": ids
                }
              ],
          "group": [],
          "interval": {
            "key": "day",
            "startDate": start_date,
            "endDate": end_date,
          },
          "cubeName": "sales",
          "cubeApiType": "TIMESERIES",
          "componentName": "measureDisplay",
#          "measures":["Royalty_utc", "total_tax_usd_utc", "units_utc"],
          "measures":[
            {
              "key": "total_tax_usd_utc"
            }
          ]
        }

      response = request(:post) do |req|
        req.url("trends/gsf/salesTrendsApp/businessareas/InternetServices/subjectareas/iTunes/vcubes/700/timeseries")
        req.body = body.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-Apple-Widget-Key'] = 'e0b80c3bf78523bfe80974d320935bfa30add02e1bff88ec2166c6bd5a706c42' # 目前固定值
        # req.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15'
        req.headers['Accept'] = 'application/json, text/plain, */*;q=0.8'
        req.headers['Accept-Language'] = 'zh-CN,zh;q=0.9'
        req.headers['Referer'] = "https://appstoreconnect.apple.com"
        req.headers['X-Requested-By'] = 'dev.apple.com' # 分析数据下载必备
        req.headers['x-requested-with'] = 'OWASP CSRFGuard Project' # 分析数据下载必备
        req.headers['csrf'] = csrf # 销售量数据下载必备
        req.headers['uicomponentname'] = 'measureDisplay'

        req.headers['Cookie'] = cookie
        req.headers["X-Apple-Id-Session-Id"] = x_apple_id_session_id

        puts(req.headers)
      end

      puts(response)
      response.body || []
    end

    def send_login_request(user, password)
      send_shared_login_request(user, password)
    end
  end
end
