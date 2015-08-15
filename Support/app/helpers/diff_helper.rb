module DiffHelper
  def extract_submodule_revisions(diff_result)
    diff_result[:lines].map do |line| 
      line[:text].gsub("Subproject commit ", "")
    end
  end

  def htmlize_highlight_trailing_whitespace (text)
    if text =~ /[ \t]+$/
      htmlize($`) + content_tag(:span, $&, :class => "trailing-whitespace") 
    else
      htmlize(text)
    end
  end
  
  def classes_for_line_type(type)
    case type
      when :deletion then ["", "code-line--del"]
      when :insertion then ["", "code-line--ins"]
      when :eof then ["code-line--eof", "code-line--eof"]
      when :cut then ["code-line--cut", "code-line--cut"]
      else
        ["", ""]
    end
  end
end