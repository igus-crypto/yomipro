# encoding: utf-8
# sort3
# チェックリストのソート

Encoding.default_external = 'UTF-8'


$stdout=open("tmp_s99.txt","w")
$stderr=open("tmp_serr.txt","w")

require 'clipboard'
require_relative 'clipboard_compat'

cbd=ClipBoard.new(__ENCODING__)
arr=cbd.getText.split("\r\n")


#p arr
class String
  def bsize
    self.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
    #"—"が実は３バイトという罠回避 "-"は１バイト
  end
end

class Array
  def p10
    sf=self.grep_v([])
    if sf[0].is_a?(Array)
      sf.map{|e| e.p10}
    else
      sf.group_by{|e| e.match(/^(.*?),/).to_s.bsize}.to_a.
        sort_by{|e| -e[0].to_i}.transpose[1].to_a.map{|e| e.sort}.flatten.
        each_slice(10).to_a.map{|e| e.join("\n")}.join("\n\n")
    end
  end
  def rep
    sf=self.grep_v([])
    if sf[0].is_a?(Array)
      sf.map{|e| e.rep}
    else
      arr=self
      rep=arr.grep(/!*([^ ,]+),([^ ,]+),([^ ,]+)/)
      arr=arr-rep
      [arr,rep]
    end
  end
  def list_sort
    sf=self.grep_v([])
    a,b,c=[],[],[]
    if sf[0].is_a?(Array)
      sf.map{|e| e.list_sort}
    else
      arr,st,z=self,"",[]
      z[0]="間中,%あいだじゅう|後,%あと|方,%ほう|皆,%みんな|頃,%ころ|"+
        "今,%いま|時,%とき|金,%かね|間,%あいだ|何,%なに|何,%なん|"+
        "ぁ,%あ|ぃ,%い|ぅ,%う|ぇ,%え|ぉ,%お"
      z[1]="頬,%ホオ|奴,%ヤツ"
      z[2]="金,-かね|良,-い"
      z[3]="金持,金持ち|持主,持ち主|真赤,真っ赤|押売,押し売|死顔,死に顔|"+
        "泣声,泣き声|あなた方,貴方がた"
      z[4]="だいじょうぶ,大丈夫|うなず,頷|たぶん,多分|だれ,誰|いま,今|い,言|き,訊"
      a[ 0]=arr.grep(%r|^[\/]|).sort_by{|e|
        e.match(%r|^!+[^,]+|).to_s.bsize}.reverse;    arr=arr-a [0]
      a[ 1]=arr.grep(%r|^[\!]|).sort_by{|e|
        e.match(%r|^!+[^,]+|).to_s.bsize}.reverse;                  arr=arr-a[ 1]
      a[ 2]=arr.grep(%r|=$|);                                       arr=arr-a[ 2]
      a[ 3]=arr.grep(%r|#{z[0]}|);                                  arr=arr-a[ 3]
      a[ 4]=arr.grep(%r|#{z[1]}|);                                  arr=arr-a[ 4]
      a[ 5]=arr.grep(%r|#{z[2]}|);                                  arr=arr-a[ 5]
      a[ 6]=arr.grep(%r|#{z[3]}|);                                  arr=arr-a[ 6]
      a[ 7]=arr.grep(%r|#{z[4]}|);                                  arr=arr-a[ 7]
      a[ 8]=arr.grep(%r|^御[\p{Han}]+,[おご]|);                     arr=arr-a[ 8]
      a[ 9]=arr.grep(%r|^[^, ]+,[ぁ-んー]+$|);                      arr=arr-a[ 9]
      a[10]=arr.grep(%r|,[+]|);                                     arr=arr-a[10]
      a[11]=arr.grep(%r|,[:]|);                                     arr=arr-a[11]
      a[12]=arr.grep(%r|ヽ|) ;                                      arr=arr-a[12]
      a[13]=arr.grep(%r|,[~]|);                                     arr=arr-a[13]
      a[14]=arr.grep(%r|,[!]|);                                     arr=arr-a[14]
      a[15]=arr.grep(%r|^[ぁ-ん]+,[%][ァ-ヴー]*$|);                 arr=arr-a[15]
      a[16]=arr.grep(%r|,[%][ァ-ヴー]*$|);                          arr=arr-a[16]
      a[17]=arr.grep(%r|^[^, ]+,[ァ-ヴー-]*$|);                     arr=arr-a[17]
      a[18]=arr.grep(%r|^[^, ]+,[ァ-ヴー][\p{Han}ァ-ヴーぁ-ん]*$|);  arr=arr-a[18]
      a[19]=arr.grep(%r|^[^, ]+,[%][ぁ-ん]*$|);                     arr=arr-a[19]
      a[20]=arr.grep(%r|,[%]|);                                     arr=arr-a[20]
      a[21]=arr.grep(%r|^[ぁ-ん]+,[-][ぁ-ん]*$|);                   arr=arr-a[21]
      a[22]=arr.grep(%r|,[-][ぁ-ん]*$|);                            arr=arr-a[22]
      a[23]=arr.grep(%r|^[ぁ-ん]+,[ぁ-ん-]*$|);                    arr=arr-a[23]
      a[24]=arr.grep(%r|,[ぁ-ん-]*$|);                             arr=arr-a[24]
      a[25]=arr.grep(%r|^[ぁ-ん]+,[’][ぁ-ん]*$|);                  arr=arr-a[25]
      a[26]=arr.grep(%r|^[^, ]+,[’][ぁ-ん]*$|);                    arr=arr-a[26]
      a[27]=arr.grep(%r|^[ぁ-ん]+,[ぁ-ん]*’$|);                    arr=arr-a[27]
      a[28]=arr.grep(%r|^[^, ]+,[ぁ-ん]*’$|);                      arr=arr-a[28]
      a[29]=arr.grep(%r|,[-]|);                                     arr=arr-a[29]
      a[30]=arr.grep(%r|^[^, ]+,[^ #=]*[-]$|);                      arr=arr-a[30]
      a[31]=arr.grep(%r|^[^, ]+,[-]|);                              arr=arr-a[31]
      a[32]=arr.grep(%r|^[^, ]+,[^ #=]*[-]|);                       arr=arr-a[32]
      a[33]=arr.grep(%r|^[^, ]+,[/]|);                              arr=arr-a[33]
      a[34]=arr.grep(%r|^[^, ]+,[’][\p{Han}]*$|);                  arr=arr-a[34]
      a[35]=arr.grep(%r|^[^, ]+,[’]|);                             arr=arr-a[35]
      a[36]=arr.grep(%r|^[^, ]+,[\p{Han}]*’$|);                    arr=arr-a[36]
      a[37]=arr.grep(%r|^[^, ]+,[^ #=]*’$|);                       arr=arr-a[37]
      a[38]=arr.grep(%r|^[^, ]+,[^ #=]*[’]|);                      arr=arr-a[38]
      a[39]=arr.grep(%r|^[^, ]+,[^ #=]*’|);                        arr=arr-a[39]
      a[40]=arr.grep(%r|^[^, ]+,[^ #=]*[\/]|);                      arr=arr-a[40]
      a[41]=arr.grep(%r|^[^, ]+,[^ #=][０-９]+$|);                  arr=arr-a[41]
      a[42]=arr.grep(%r|^[^, ]+,[^ #=]*[０-９]|);                   arr=arr-a[42]
      a[43]=arr.grep(%r|^[^, ]+,[^ #=]*[ぁ-ん]|);                   arr=arr-a[43]
      a[44]=arr.grep(%r|^[^, ]+,[\p{Han}]+$|);                      arr=arr-a[44]
      a[45]=arr.grep(%r|^[^, ]+,[\p{Han}]|);                      arr=arr-a[45]
      a[46]=arr.grep(%r|[#][ァ-ヴー]*$|);                           arr=arr-a[46]
      a[47]=arr.grep(%r|[#][\p{Han}ァ-ヴー]*$|);                    arr=arr-a[47]
      a[48]=arr.grep(%r|[#][ぁ-ん]*$|);                             arr=arr-a[48]
      a[49]=arr.grep(%r|[#][\p{Han}ぁ-ん]*$|);                      arr=arr-a[49]
      a[50]=arr.grep(%r|[#]|);                                      arr=arr-a[50]
      a[51]=arr.grep(%r|[=]|);                                      arr=arr-a[51]
      a[52]=arr
      a.each_with_index{|e,i| print "a#{i}=";p e}
      ##a=(0..60).to_a
      #b=[a[ 0],a[ 1],a[ 9],a[10],a[11],a[12],a[16],a[19],a[20],
      #   a[24],a[18],a[17],a[22],a[42],a[38],a[43],a[15],a[14],
      #   a[26],a[28],a[29],a[30],a[36],a[31],a[34],a[35],a[39],
      #   a[40],a[41],a[33],a[32],a[23],a[21],a[25],a[37],a[27],
      #   a[44],a[ 3],a[ 4],a[ 5],a[ 8],a[ 6],a[ 7],a[45],a[46],
      #   a[47],a[48],a[49],a[13],a[50],a[51],a[ 2]]
      ##p b.sort
      b= [a[ 0],a[ 1],a[ 9],a[10],a[11],a[12],a[16],a[15],a[19],
          a[ 3],a[14],a[22],a[23],a[29],a[ 5],a[21],a[32],a[20],
          a[24],a[18],a[17],a[42],a[40],a[33],a[43],a[30],a[31],
          a[41],a[44],a[45],a[ 4],a[ 8],a[ 6],a[ 7],a[25],a[26],
          a[34],a[35],a[38],a[28],a[36],a[39],a[37],a[27],a[46],
          a[47],a[48],a[49],a[50],a[13],a[51],a[52],a[ 2]]
      b.each_with_index{|e,i| print "b#{i}=";p e}
      b.rep
    end
  end
end

arr=arr.grep_v(/^$|^最終更新日：/)
st=""
st="最終更新日：#{Time.new.strftime("%Y.%m.%d")}\n\n"
arr=arr.uniq
#print "arr=";p arr

#重複要素のチェック
jyu=arr.map{|e| e.gsub(/^(!+[^,]+),[+-]?([^, ]+)/,'\1,\2')}.
  group_by{|e| e}.select{|k,v| v.size>1}.map(&:first)
jyu.map{|e| print "e=";p e}
print "jyu=";p jyu
#jyu.map{|e| f=e.split(",");arr=arr.grep_v(/^[!]*#{f[0]},[+-]?#{f[1]}/)}
#jyu=jyu.map{|e| f=e.split(",");"!!#{f[0]},+#{f[1]}"}

#ルビ付き分離１
rb1=arr.grep(/,.*《.*》.*/);arr=arr-rb1
print "rb1=";p rb1

#ルビ付き分離
rbt=arr.grep(/《.*》/);arr=arr-rbt
rbt=rbt.partition{|e| /=>$/=~e}[0]
rbt=rbt.group_by{|e| e.gsub(%r|^(!+)[^!].*|,'\1').size}.
  to_a.sort_by{|e| -e[0].to_i}.transpose[1]
print "rbt=";p rbt
#!分離
p arr.grep(%r|^!|).group_by{|e| e.gsub(%r|^(!+)[^!].*|,'\1').size}.to_a.sort_by{|e| -e[0].to_i}
ext=arr.grep(%r|^!|).group_by{|e| e.gsub(%r|^(!+)[^!].*|,'\1').size}.
  to_a.sort_by{|e| -e[0].to_i}.map{|e| e[1]}
arr=arr-ext.flatten
rep=arr.grep(%r|!*([^ ,]+),([^ ,]+),([^ ,]+)|)
arr=arr-rep
print "ext=";p ext
st+=[rb1].list_sort.p10.join("\n\n")+"\n\n" if rb1
st+=[jyu,ext,arr,rep].list_sort.p10.join("\n\n")+"\n\n"
rbt.map{|e| st+=e.list_sort.p10.join("\n\n")+"\n\n"} if rbt
st=st.gsub(%r|\R{3,}|,"\n\n")

cbd.setText(st)

__END__




