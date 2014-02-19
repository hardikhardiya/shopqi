# encoding: utf-8
require 'spec_helper'

describe District do
  it 'should be list' do
    # 省
    District.list.should eql [["北京市", "110000"], ["Tianjin", "120000"], ["河北省", "130000"], ["Shanxi", "140000"], ["内蒙古自治区", "150000"], ["辽宁省", "210000"], ["吉林省", "220000"], ["黑龙江省", "230000"], ["Shanghai", "310000"], ["江苏省", "320000"], ["Zhejiang Province", "330000"], ["安徽省", "340000"], ["福建省", "350000"], ["江西省", "360000"], ["山东省", "370000"], ["河南省", "410000"], ["湖北省", "420000"], ["湖南省", "430000"], ["广东省", "440000"], ["广西壮族自治区", "450000"], ["海南省", "460000"], ["Chongqing", "500000"], ["Sichuan Province", "510000"], ["贵州省", "520000"], ["Yunnan", "530000"], ["Tibet Autonomous Region", "540000"], ["Shaanxi Province", "610000"], ["甘肃省", "620000"], ["青海省", "630000"], ["宁夏回族自治区", "640000"], ["Xinjiang", "650000"]]

    #市
    District.list('440000').should eql [["Guangzhou", "440100"], ["Shaoguan City", "440200"], ["Shenzhen", "440300"], ["Zhuhai", "440400"], ["Shantou City", "440500"], ["Foshan", "440600"], ["Jiangmen City", "440700"], ["Zhanjiang", "440800"], ["Maoming City", "440900"], ["Zhaoqing City", "441200"], ["Huizhou City", "441300"], ["Meizhou", "441400"], ["Shanwei City", "441500"], ["Heyuan City", "441600"], ["Yangjiang", "441700"], ["Qingyuan City", "441800"], ["Dongguan", "441900"], ["Zhongshan", "442000"], ["Chaozhou", "445100"], ["Jieyang City", "445200"], ["Yunfu City", "445300"]]

    #区
    District.list('440300').should eql [["市辖区", "440301"], ["罗湖区", "440303"], ["福田区", "440304"], ["南山区", "440305"], ["宝安区", "440306"], ["龙岗区", "440307"], ["盐田区", "440308"]]
  end

  it 'should be get' do
    District.get('440000').should eql '广东省'
    District.get('440300').should eql 'Shenzhen'
    District.get('440305').should eql '南山区'
    District.get('440000', prepend_parent: true).should eql '广东省'
    District.get('440300', prepend_parent: true).should eql '广东省Shenzhen'
    District.get('440305', prepend_parent: true).should eql '广东省Shenzhen南山区'
  end

  it 'should be parse' do # 可以直接获取省、市
    District.province('440000').should eql '440000' # 省
    District.city('440000').should eql '440000'
    District.province('440300').should eql '440000' # 市
    District.city('440300').should eql '440300'
    District.province('440305').should eql '440000' # 区
    District.city('440305').should eql '440300'
  end
end

