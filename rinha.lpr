program rinha;

uses
  Web,JS, fpjson, fpjsonjs, sysutils;

var
  GInput: TJSHTMLInputElement;
  ulText,
  lbText:TJSHTMLElement;
  LFile: TJSHTMLFile;

function LerArquivo(aEvent: TEventListenerEvent): Boolean;
var
  ni:LongInt;
  t: TDateTime;
  LFileContent: String;

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
        ul:=document.createElement('ul');
        ul['class']:='nested';
        montaLista(oo.Value,ul);
        li.appendChild(ul);
        el.appendChild(li);
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
        end;
        el.appendChild(lii);
        inc(ni);
      end;
    end;
  end;

begin
  t:=now;
  LFileContent := String(TJSFileReader(aEvent.Target).Result);
  try
    ulText.innerText:='';
    montaLista(GetJSON(LFileContent,true),ulText);
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
    t:=now-t;
    lbText.innerHTML:=LFileContent.Length.ToString+' bytes com '+
                      ni.ToString+' itens em '+
                      FormatDateTime('nn:ss.zzz ',t);
  except
    lbText.innerHTML:='<center><pre><font color="red">Arquivo JSON inválido.</font></pre></center>';
  end;
end;

function NovoArquivo(aEvent: TEventListenerEvent): Boolean;
var
  LReader: TJSFileReader;
begin
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

