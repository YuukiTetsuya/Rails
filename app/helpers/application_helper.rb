module ApplicationHelper
  
  # ページごとの完全なタイトルを返す。
  def full_title(page_title = '')                                               #読み出し時にfull_title("文字")を使うと、文字の部分がpage_title=''に格納される。
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty? #page_titleは空でしょうか？
      base_title
    else
      page_title + " | " + base_title
    end
  end
end