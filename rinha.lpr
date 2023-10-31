program rinha;

uses
  Web,JS, fpjson, fpjsonjs, sysutils;

var
  FInput: TJSHTMLInputElement;
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
    li,lii,ul,sp,href:TJSElement;
  begin
    for oo in jData do begin
      // se object or array, monta linha e usa recursão para ver os itens
      if oo.Value.JSONType in [jtObject, jtArray] then begin
        case oo.Value.JSONType of
          jtObject : tp:=' : Object';
          jtArray  : tp:=' : Array';
        end;
        sp:=document.createElement('span');
        inc(ne);
        sp['class']:='box';
        sp.innerText:=oo.Key+tp+'['+oo.Value.Count.ToString+' itens]';
        li:=document.createElement('li');
        inc(ne);
        li.appendChild(sp);
        ul:=document.createElement('ul');
        inc(ne);
        ul['class']:='nested';
        montaLista(oo.Value,ul);
        li.appendChild(ul);
        el.appendChild(li);
        inc(ni);
      end else begin
        // verifica tipo do conteúdo para apresentar resultado
        case oo.Value.JSONType of
          jtNull: vl:='null';
          jtNumber: vl :=oo.Value.AsFloat.ToString;
          jtString: vl := oo.Value.AsString;
        else
          vl:=oo.Value.AsString;
        end;
        lii:=document.createElement('li');
        inc(ne);
        sp:=document.createElement('i');
        inc(ne);
        sp.innerText:=oo.Key+' = ';
        lii.appendChild(sp);
        sp:=document.createElement('b');
        inc(ne);
        if oo.Value.JSONType = jtString then begin
          // se conteúdo inicia por http, entaão cria <a href=
          if vl.StartsWith('http') then begin
            href:=document.createElement('a');
            inc(ne);
            href['href']:=vl;
            href['target']:='_blank';
            href.innerText:=vl;
            sp.append(href);
          end else
            sp.innerText:='"'+vl+'"'
        end else begin
          sp.innerText:=vl;
        end;
        lii.appendChild(sp);
        el.appendChild(lii);
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
    montaLista(JSON,ulText);
    tr:=now;
    // executa JS diretamente para ativar expand/collapse do itens
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
  ulText.innerText:='';
  LFile := FInput.Files[0];
  LReader := TJSFileReader.New;
  LReader.OnLoad := @LerArquivo;
  lbText.innerHTML:= '<center><div id="loader" class="loader"></div></center>';
  LReader.ReadAsText(LFile);
end;

begin
  FInput := TJSHTMLInputElement(Document.GetElementByID('input'));
  FInput.OnChange := @NovoArquivo;
  lbText:=TJSHTMLElement(document.getElementById('output'));
  ulText:=TJSHTMLElement(document.getElementById('myUL'));
end.

