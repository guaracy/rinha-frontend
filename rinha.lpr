program rinha;

uses
  Web,JS, fpjson, fpjsonjs, sysutils;

var
  GInput: TJSHTMLInputElement;
  ulText,
  lbText:TJSHTMLElement;
  LFile: TJSHTMLFile;
  ti:TDateTime;

function LerArquivo(aEvent: TEventListenerEvent): Boolean;
var
  ni,ne:LongInt;
  tl,tp,tr,tf: TDateTime;
  LFileContent: String;
  JSON:TJSONData;

  procedure montaLista(jData : TJSONData;el:TJSElement);
  var
    oo: TJSONEnum;
    tp, vl: String;
    li,lii,ul,sp,spi:TJSElement;
    i,j: Integer;
  begin
    for oo in jData do begin
      if oo.Value.JSONType in [jtObject, jtArray] then begin
        case oo.Value.JSONType of
          jtObject : tp:=' : Object';
          jtArray  : tp:=' : Array';
        end;
        sp:=document.createElement('span');
        sp['class']:='box';
        sp.innerText:=oo.Key+tp+'['+oo.Value.Count.ToString+']';
        li:=document.createElement('li');
        li.appendChild(sp);
        inc(ne);
        ul:=document.createElement('ul');
        ul['class']:='nested';
        montaLista(oo.Value,ul);
        li.appendChild(ul);
        inc(ne);
        el.appendChild(li);
        inc(ne);
        inc(ni);
      end else begin
        case oo.Value.JSONType of
          jtNull: vl:='null';
          jtNumber: vl :=oo.Value.AsFloat.ToString;
          jtString: vl := oo.Value.AsString;
        else
          vl:=oo.Value.AsString;
        end;
        lii:=document.createElement('li');
        sp:=document.createElement('i');
        sp.innerText:=oo.Key+' = ';
        lii.appendChild(sp);
        inc(ne);
        if oo.Value.JSONType = jtString then begin
          if vl.StartsWith('http') then begin
            sp:=document.createElement('a');
            sp['href']:=vl;
            sp['target']:='_blank';
            sp.innerText:=vl;
          end else begin
            sp:=document.createElement('b');
            sp.innerText:='"'+vl+'"';
          end;
          lii.appendChild(sp);
          inc(ne);
        end;
        el.appendChild(lii);
        inc(ne);
        inc(ni);
      end;
    end;
  end;

begin
  LFileContent := String(TJSFileReader(aEvent.Target).Result);
  tl:=now;
  try
    JSON:=GetJSON(LFileContent,true);
    tp:=now;
    ulText.innerText:='';
    montaLista(JSON,ulText);
    tr:=now;
    asm
      var toggler = document.getElementsByClassName("box");
      var i;
      for (i = 0; i < toggler.length; i++) {
        toggler[i].addEventListener("click", function() {
          this.parentElement.querySelector(".nested").classList.toggle("active");
          this.classList.toggle("check-box");
        });
      }
    end;
    tf:=now;
    lbText.innerHTML:=Format('%u bytes em:<b>%s</b> / %u itens em:<b>%s</b> / %u elementos em:<b>%s</b> / total:<b>%s</b>',[
    LFileContent.Length,
    FormatDateTime('nn:ss.zzz ',tl-ti),
    ni,
    FormatDateTime('nn:ss.zzz ',tp-tl),
    ne,
    FormatDateTime('nn:ss.zzz ',tr-tp),
    FormatDateTime('nn:ss.zzz ',tf-ti)]);

    //.ToString+' bytes com '+
    //                  ni.ToString+' itens em '+
    //                  FormatDateTime('nn:ss.zzz ',t);
  except
    lbText.innerHTML:='<center><pre><font color="red">Arquivo JSON inválido.</font></pre></center>';
  end;
end;

function NovoArquivo(aEvent: TEventListenerEvent): Boolean;
var
  LReader: TJSFileReader;
begin
  ti:=now;
  LFile := GInput.Files[0];
  LReader := TJSFileReader.New;
  LReader.OnLoad := @LerArquivo;
  lbText.innerHTML:= '<center><div id="loader" class="loader"></div></center>';
  LReader.ReadAsText(LFile);
end;

begin
  GInput := TJSHTMLInputElement(Document.GetElementByID('input'));
  GInput.OnChange := @NovoArquivo;
  lbText:=TJSHTMLElement(document.getElementById('output'));
  ulText:=TJSHTMLElement(document.getElementById('myUL'));
end.

