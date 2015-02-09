<map version="1.0.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1422990720586" ID="ID_1767872755" MODIFIED="1423223675301" TEXT="Business Security">
<attribute NAME="now" VALUE="04/02/2015"/>
<attribute NAME="start" VALUE="01/01/2015"/>
<attribute NAME="period" VALUE="6m"/>
<node CREATED="1422990750584" ID="ID_588142405" MODIFIED="1423225886140" POSITION="right" TEXT="Projetos">
<node CREATED="1422990756819" ID="ID_1079569510" MODIFIED="1423252709472" TEXT="Emvision">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      <font size="2">\note{ </font>
    </p>
    <p>
      <font size="2">Descri&#231;&#227;o do projeto ou da tarefa quando necess&#225;rio </font>
    </p>
    <p>
      <font size="2">} </font>
    </p>
    <p>
      
    </p>
    <p>
      <font size="2">\journal { </font>
    </p>
    <p>
      <font size="2">date: 04/01/2015 </font>
    </p>
    <p>
      <font size="2">author: Botafogo </font>
    </p>
    <p>
      <font size="2">alert: red </font>
    </p>
    <p>
      <font size="2">summary: este &#233; um sum&#225;rio do alerta </font>
    </p>
    <p>
      <font size="2">details: {esta &#233; uma explica&#231;&#227;o um pouco mais extensa} </font>
    </p>
    <p>
      <font size="2">}</font>
    </p>
  </body>
</html></richcontent>
<attribute NAME="id" VALUE="p1"/>
<node CREATED="1422990776480" ID="ID_1599618568" MODIFIED="1423252709472" STYLE="fork" TEXT="Apresenta&#xe7;&#xe3;o do projeto">
<attribute NAME="effort" VALUE="4h"/>
<attribute NAME="effortdone" VALUE="2h"/>
<attribute NAME="start" VALUE="15/02/2015"/>
<attribute NAME="complete" VALUE="80"/>
<attribute NAME="id" VALUE="apres_proj"/>
<attribute NAME="allocate" VALUE="danifer"/>
</node>
<node CREATED="1422990780218" ID="ID_1263886405" MODIFIED="1423227538806" TEXT="Aquisi&#xe7;&#xe3;o">
<attribute NAME="depends" VALUE="!apres_proj"/>
<attribute NAME="duration" VALUE="90d"/>
<attribute NAME="id" VALUE="aquisicao"/>
</node>
<node CREATED="1422990781913" ID="ID_1731362053" MODIFIED="1423226927356" TEXT="Planejamento">
<attribute NAME="effort" VALUE="10h"/>
<attribute NAME="priority" VALUE="900"/>
</node>
<node CREATED="1422990784480" ID="ID_1010700599" MODIFIED="1423230120555" TEXT="Implanta&#xe7;&#xe3;o">
<attribute NAME="effort" VALUE="10h"/>
<attribute NAME="alert" VALUE="yellow"/>
<attribute NAME="depends" VALUE="!aquisicao"/>
<attribute NAME="id" VALUE="impl"/>
</node>
<node CREATED="1423226941597" ID="ID_1658759139" MODIFIED="1423226945059" TEXT="Fine-tuning"/>
<node CREATED="1423230032492" ID="ID_1580219272" MODIFIED="1423230104971" TEXT="Termino do projeto">
<attribute NAME="milestone" VALUE=""/>
<attribute NAME="depends" VALUE="!impl"/>
</node>
</node>
<node CREATED="1422990761699" FOLDED="true" ID="ID_1265193727" MODIFIED="1423227011855" TEXT="Projeto 2">
<attribute NAME="allocate" VALUE="helbber"/>
<node CREATED="1422990791431" ID="ID_1639716790" MODIFIED="1423058056854" TEXT="T1">
<attribute NAME="duration" VALUE="1d"/>
<attribute NAME="depends" VALUE="!!p1.lev_req"/>
</node>
<node CREATED="1422990793608" ID="ID_1169277099" MODIFIED="1423056277875" TEXT="T2">
<attribute NAME="effort" VALUE="10h"/>
</node>
<node CREATED="1422990795338" ID="ID_1400620575" MODIFIED="1423056281904" TEXT="T3">
<attribute NAME="effort" VALUE="10h"/>
</node>
</node>
<node CREATED="1422990765674" ID="ID_29430515" MODIFIED="1423252709472" TEXT="Projeto 3">
<attribute NAME="effort" VALUE="10h"/>
</node>
</node>
<node CREATED="1423223684412" ID="ID_28174001" MODIFIED="1423252477967" POSITION="right" TEXT="Servi&#xe7;os">
<node CREATED="1423223692770" ID="ID_1119375428" MODIFIED="1423252709472" TEXT="CIELO">
<attribute NAME="dailymin" VALUE="2h"/>
<attribute NAME="dailymax" VALUE="2h"/>
<attribute NAME="length" VALUE="6m"/>
<attribute NAME="priority" VALUE="1000"/>
</node>
<node CREATED="1423223878695" ID="ID_1859895268" MODIFIED="1423224617705" TEXT="Monitora&#xe7;&#xe3;o">
<attribute NAME="dailymin" VALUE="6h"/>
<attribute NAME="dailymax" VALUE="6h"/>
</node>
</node>
</node>
</map>
