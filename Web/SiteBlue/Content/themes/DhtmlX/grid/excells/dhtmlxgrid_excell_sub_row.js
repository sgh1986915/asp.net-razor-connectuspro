//v.3.0 build 110713

/*
Copyright DHTMLX LTD. http://www.dhtmlx.com
To use this component please contact sales@dhtmlx.com to obtain license
*/
function eXcell_sub_row(b){if(b)this.cell=b,this.grid=this.cell.parentNode.grid;this.getValue=function(){return this.grid.getUserData(this.cell.parentNode.idd,"__sub_row")};this._setState=function(a,b){(b||this.cell).innerHTML="<img src='"+this.grid.imgURL+a+"' width='18' height='18' />";(b||this.cell).firstChild.onclick=this.grid._expandMonolite};this.open=function(){this.cell.firstChild.onclick(null,!0)};this.close=function(){this.cell.firstChild.onclick(null,!1,!0)};this.isOpen=function(){return!!this.cell.parentNode._expanded};
this.setValue=function(a){a&&this.grid.setUserData(this.cell.parentNode.idd,"__sub_row",a);this._setState(a?"plus.gif":"blanc.gif")};this.setContent=function(a){this.cell.parentNode._expanded?(this.cell.parentNode._expanded.innerHTML=a,this.grid._detectHeight(this.cell.parentNode._expanded,this.cell,this.cell.parentNode._expanded.scrollHeight)):(this.cell._previous_content=null,this.setValue(a),this.cell._sub_row_type=null)};this.isDisabled=function(){return!0};this.getTitle=function(){return this.grid.getUserData(this.cell.parentNode.idd,
"__sub_row")?"click to expand|collapse":""}}eXcell_sub_row.prototype=new eXcell;function eXcell_sub_row_ajax(b){this.base=eXcell_sub_row;this.base(b);this.setValue=function(a){a&&this.grid.setUserData(this.cell.parentNode.idd,"__sub_row",a);this.cell._sub_row_type="ajax";this._setState(a?"plus.gif":"blanc.gif")}}eXcell_sub_row_ajax.prototype=new eXcell_sub_row;
function eXcell_sub_row_grid(b){this.base=eXcell_sub_row;this.base(b);this.setValue=function(a){a&&this.grid.setUserData(this.cell.parentNode.idd,"__sub_row",a);this.cell._sub_row_type="grid";this._setState(a?"plus.gif":"blanc.gif")};this.getSubGrid=function(){return!b._sub_grid?null:b._sub_grid}}eXcell_sub_row_grid.prototype=new eXcell_sub_row;
dhtmlXGridObject.prototype._expandMonolite=function(b,a,d){var f=this.parentNode,e=f.parentNode,c=e.grid;if(b||window.event)!d&&!e._expanded&&c.editStop(),(b||event).cancelBubble=!0;var i=c.getUserData(e.idd,"__sub_row");if(!c._sub_row_editor)c._sub_row_editor=new eXcell_sub_row(f);if(i){if(e._expanded&&!a){c._sub_row_editor._setState("plus.gif",f);f._previous_content=e._expanded;c.objBox.removeChild(e._expanded);e._expanded=!1;e.style.height=(e.oldHeight||20)+"px";f.style.height=(e.oldHeight||20)+
"px";if(c._fake)c._fake.rowsAr[e.idd].style.height=(e.oldHeight||20)+"px";for(var g=0;g<e.cells.length;g++)e.cells[g].style.verticalAlign="middle",e.cells[g].style.paddingTop="0px";delete c._flow[e.idd];c._correctMonolite();e._expanded.ctrl=null}else if(!e._expanded&&!d){c._sub_row_editor._setState("minus.gif",f);e.oldHeight=f.offsetHeight;if(f._previous_content){var h=f._previous_content;h.ctrl=f;c.objBox.appendChild(h);c._detectHeight(h,f,parseInt(h.style.height))}else{h=document.createElement("DIV");
h.ctrl=f;if(f._sub_row_type)c._sub_row_render[f._sub_row_type](c,h,f,i);else h.innerHTML=i;h.style.cssText="position:absolute; left:0px; top:0px; overflow:auto; font-family:Tahoma; font-size:8pt; margin-top:2px; margin-left:4px;";h.className="dhx_sub_row";c.objBox.appendChild(h);c._detectHeight(h,f)}if(!c._flow)c.attachEvent("onGridReconstructed",function(){this.pagingOn||this._srnd?this._collapsMonolite():this._correctMonolite()}),c.attachEvent("onResizeEnd",function(){this._correctMonolite(!0)}),
c.attachEvent("onAfterCMove",function(){this._correctMonolite(!0)}),c.attachEvent("onDrop",function(){this._correctMonolite(!0)}),c.attachEvent("onBeforePageChanged",function(){this._collapsMonolite();return!0}),c.attachEvent("onGroupStateChanged",function(){this._correctMonolite();return!0}),c.attachEvent("onFilterEnd",function(){this._collapsMonolite()}),c.attachEvent("onUnGroup",function(){this._collapsMonolite()}),c.attachEvent("onPageChanged",function(){this._collapsMonolite()}),c.attachEvent("onXLE",
function(){this._collapsMonolite()}),c.attachEvent("onClearAll",function(){for(var a in this._flow)this._flow[a]&&this._flow[a].parentNode&&this._flow[a].parentNode.removeChild(this._flow[a]);this._flow=[]}),c.attachEvent("onEditCell",function(a,b,c){a!==2&&this._flow[b]&&this.cellType[c]!="ch"&&this.cellType[c]!="ra"&&this._expandMonolite.apply(this._flow[b].ctrl.firstChild,[0,!1,!0]);return!0}),c.attachEvent("onCellChanged",function(a,b){if(this._flow[a]){var c=this.cells(a,b).cell;c.style.verticalAlign=
"top";c.style.paddingTop="3px"}}),c._flow=[];c._flow[e.idd]=h;c._correctMonolite();for(g=0;g<e.cells.length;g++)e.cells[g].style.verticalAlign="top",e.cells[g].style.paddingTop="3px";if(c._fake)for(var j=c._fake.rowsAr[e.idd],g=0;g<j.cells.length;g++)j.cells[g].style.verticalAlign="top",j.cells[g].style.paddingTop="3px";f.style.paddingTop="1px";e._expanded=h}c._ahgr&&c.setSizes();c.parentGrid&&c.callEvent("onGridReconstructed",[]);c.callEvent("onSubRowOpen",[e.idd,!!e._expanded])}};
dhtmlXGridObject.prototype._sub_row_render={ajax:function(b,a,d,f){a.innerHTML="Loading...";var e=new dtmlXMLLoaderObject(function(){a.innerHTML=e.xmlDoc.responseText;var c=e.xmlDoc.responseText.match(/<script[^>]*>([^<]+)<\/script>/g);if(c)for(var f=0;f<c.length;f++)eval(c[f].replace(/<([\/]{0,1})s[^>]*>/g,""));b._detectHeight(a,d);b._correctMonolite();b.setUserData(d.parentNode.idd,"__sub_row",e.xmlDoc.responseText);d._sub_row_type=null;b._ahgr&&b.setSizes();b.callEvent("onSubAjaxLoad",[d.parentNode.idd,
e.xmlDoc.responseText])},this,!0,!0);e.loadXML(f)},grid:function(b,a,d,f){d._sub_grid=new dhtmlXGridObject(a);b.skin_name&&d._sub_grid.setSkin(b.skin_name);d._sub_grid.parentGrid=b;d._sub_grid.setImagePath(b.imgURL);d._sub_grid.enableAutoHeight(!0);d._sub_grid._delta_x=d._sub_grid._delta_y=null;d._sub_grid.attachEvent("onGridReconstructed",function(){b._detectHeight(a,d,d._sub_grid.objBox.scrollHeight+d._sub_grid.hdr.offsetHeight+(this.ftr?this.ftr.offsetHeight:0));b._correctMonolite();this.setSizes();
b.parentGrid&&b.callEvent("onGridReconstructed",[])});b.callEvent("onSubGridCreated",[d._sub_grid,d.parentNode.idd,d._cellIndex,f])&&d._sub_grid.loadXML(f,function(){b._detectHeight(a,d,d._sub_grid.objBox.scrollHeight+d._sub_grid.hdr.offsetHeight+(d._sub_grid.ftr?d._sub_grid.ftr.offsetHeight:0));d._sub_grid.objBox.style.overflow="hidden";b._correctMonolite();d._sub_row_type=null;b.callEvent("onSubGridLoaded",[d._sub_grid,d.parentNode.idd,d._cellIndex,f])&&b._ahgr&&b.setSizes()})}};
dhtmlXGridObject.prototype._detectHeight=function(b,a,d){var f=a.offsetLeft+a.offsetWidth;b.style.left=f+"px";b.style.width=Math.max(0,a.parentNode.offsetWidth-f-4)+"px";d=d||b.scrollHeight;b.style.overflow="hidden";b.style.height=d+"px";var e=a.parentNode;a.parentNode.style.height=(e.oldHeight||20)+3+d*1+"px";a.style.height=(e.oldHeight||20)+3+d*1+"px";if(this._fake){var c=this._fake.rowsAr[a.parentNode.idd];c.style.height=(e.oldHeight||20)+3+d*1+"px"}};
dhtmlXGridObject.prototype._correctMonolite=function(b){if(!this._in_correction){this._in_correction=!0;for(var a in this._flow)if(this._flow[a]&&this._flow[a].tagName=="DIV")if(this.rowsAr[a])if(this.rowsAr[a].style.display=="none")this.cells4(this._flow[a].ctrl).close();else{if(this._flow[a].style.top=this.rowsAr[a].offsetTop+(this.rowsAr[a].oldHeight||20)+"px",b){var d=this._flow[a].ctrl.offsetLeft+this._flow[a].ctrl.offsetWidth;this._flow[a].style.left=d+"px";this._flow[a].style.width=this.rowsAr[a].offsetWidth-
d-4+"px"}}else this._flow[a].ctrl=null,this.objBox.removeChild(this._flow[a]),delete this._flow[a];this._in_correction=!1}};dhtmlXGridObject.prototype._collapsMonolite=function(){for(var b in this._flow)this._flow[b]&&this._flow[b].tagName=="DIV"&&this.rowsAr[b]&&this.cells4(this._flow[b].ctrl).close()};

//v.3.0 build 110713

/*
Copyright DHTMLX LTD. http://www.dhtmlx.com
To use this component please contact sales@dhtmlx.com to obtain license
*/