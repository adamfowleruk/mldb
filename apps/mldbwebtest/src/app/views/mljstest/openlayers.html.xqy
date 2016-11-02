xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";

declare option xdmp:mapping "false";

(: use the vh:required method to force a variable to be passed. it will throw an error
 : if the variable is not provided by the controller :)
(:
  declare variable $title as xs:string := vh:required("title");
    or
  let $title as xs:string := vh:required("title");
:)

(: grab optional data :)
(:
  declare variable $stuff := vh:get("stuff");
    or
  let $stuff := vh:get("stuff")
:)

<div xmlns="http://www.w3.org/1999/xhtml" class="mljstest openlayers">
<link rel="stylesheet" type="text/css" href="/css/mljs/widgets.css" />
<script type="text/javascript" src="/js/mljs/mljs.js"></script>
<script type="text/javascript" src="/js/mljs/mljs-xhr2.js"></script>
<script type="text/javascript" src="/js/OpenLayers-2.13.1/OpenLayers.debug.js"></script> <!-- debug deployment only - remove '.debug' for production use -->
<script type="text/javascript" src="/js/mljstest/angular.js"></script>

<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?sensor=false"></script> 
<!-- need to be online for this -->
<script type="text/javascript" src="/js/mljs/mljs-angular.js"></script>

<script type="text/javascript" src="/js/mljs/widgets.js"></script>
<script type="text/javascript" src="/js/mljs/widget-search.js"></script>
<script type="text/javascript" src="/js/mljs/widget-openlayers.js"></script>
<script type="text/javascript" src="/js/mljs/widget-address.js"></script>
<script type="text/javascript" src="/js/heatmap/heatmap.js"></script>
<script type="text/javascript" src="/js/heatmap/heatmap-openlayers.js"></script>
    <script>OpenLayers.Console = window.console || OpenLayers.Console;</script> <!-- debug deployment only -->

<script type="text/javascript" src="/js/mljstest/page-mljstest-openlayers.js"></script>
  <div id='appwrapper' ng-app="myApp" ng-controller="SampleCtrl">  

<span id="searchContext" mljs-search-context="" optionsName="attractions" mljs="mljs" options="ob"></span>
               
<span id="geoContext" mljs-geo-context="" mljs="mljs"></span>


 <div class="container_12"> 
   <div id="hint" class="grid_12"><i>Hint: Type in 'Westminster, London, UK' to recenter map</i></div>
 </div>
 <div class="container_12"> 
   <div id="errors" mljs-error ="" class="grid_12"></div>
 </div>
 <div class="container_12"> 
   <div id="addressbar" mljs-address-bar = "" mljs-props="addressbarProps"  contextIds="['searchContext','geoContext']" class="grid_12">address</div>
 </div>
 <div class="container_12"> 
   <div id="map" mljs-open-layers="" contextIds="['searchContext','geoContext']" init-func="initOpenLayers(widget)" class="grid_12" style="height: 300px;">Map</div>
 </div>
 <div class="container_12"> 
   <div id="selection" mljs-search-selection="" contextIds="['searchContext','geoContext']" init-func="initSelection(widget)" class="grid_12">Selection</div>
 </div>
 <div class="container_12"> 
   <div id="results" mljs-search-results="" class="grid_8" contextIds="searchContext"></div>
 </div>
</div> 
</div>

