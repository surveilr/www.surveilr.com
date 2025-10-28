import{E as p,T as d,i as u,a as v,x as h}from"./assets/lit-element-CA3xe_EJ.js";
import{n as g,r as f,t as b}from"./assets/state-DQ3nVIzR.js";/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */const m={CHILD:2},w=i=>(...t)=>({_$litDirective$:i,values:t});class H{constructor(t){}get _$AU(){return this._$AM._$AU}_$AT(t,e,s){this._$Ct=t,this._$AM=e,this._$Ci=s}_$AS(t,e){return this.update(t,e)}update(t,e){return this.render(...e)}}/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */class a extends H{constructor(t){if(super(t),this.it=p,t.type!==m.CHILD)throw Error(this.constructor.directiveName+"() can only be used in child bindings")}render(t){if(t===p||t==null)return this._t=void 0,this.it=t;if(t===d)return t;if(typeof t!="string")throw Error(this.constructor.directiveName+"() called with a non-string value");if(t===this.it)return this._t;this.it=t;const e=[t];return e.raw=e,this._t={_$litType$:this.constructor.resultType,strings:e,values:[]}}}a.directiveName="unsafeHTML",a.resultType=1;const V=w(a);var C=Object.defineProperty,$=Object.getOwnPropertyDescriptor,c=(i,t,e,s)=>{for(var r=s>1?void 0:s?$(t,e):t,n=i.length-1,l;n>=0;n--)(l=i[n])&&(r=(s?l(t,e,r):l(r))||r);return s&&r&&C(t,e,r),r};let o=class extends v{constructor(){super(...arguments),this.content="",this.visible=!1}toggleVisibility(){this.visible=!this.visible}convertNewlinesToParagraphs(i){return i.split(`
`).filter(e=>e.trim()!=="").map(e=>`<p>${e}</p>`).join("")}render(){return h`
    <div class="relative group">     
    
      <div @click="${this.toggleVisibility}" class="icon">
        <svg fill="none" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
          <path d="M17 5H7V7H17V5Z" fill="currentColor"></path>
          <path d="M7 9H9V11H7V9Z" fill="currentColor"></path>
          <path d="M9 13H7V15H9V13Z" fill="currentColor"></path>
          <path d="M7 17H9V19H7V17Z" fill="currentColor"></path>
          <path d="M13 9H11V11H13V9Z" fill="currentColor"></path>
          <path d="M11 13H13V15H11V13Z" fill="currentColor"></path>
          <path d="M13 17H11V19H13V17Z" fill="currentColor"></path>
          <path d="M15 9H17V11H15V9Z" fill="currentColor"></path>
          <path d="M17 13H15V19H17V13Z" fill="currentColor"></path>
          <path clip-rule="evenodd" d="M3 3C3 1.89543 3.89543 1 5 1H19C20.1046 1 21 1.89543 21 3V21C21 22.1046 20.1046 23 19 23H5C3.89543 23 3 22.1046 3 21V3ZM5 3H19V21H5V3Z" fill="currentColor" fill-rule="evenodd"></path>
        </svg>
      </div>

      ${this.visible?h`
            <div
              id="calculation-container"
              class="calculation-container popup"              
            >
              <div class="header">
                <div class="header-title">Calculations</div>
                <div @click="${this.toggleVisibility}" class="icon">
                  <svg viewBox="0 0 32 32" width="20" height="20" xmlns="http://www.w3.org/2000/svg">
                    <g id="cross">
                      <line x1="7" x2="25" y1="7" y2="25" stroke="black" stroke-width="2" stroke-linecap="round"></line>
                      <line x1="7" x2="25" y1="25" y2="7" stroke="black" stroke-width="2" stroke-linecap="round"></line>
                    </g>
                  </svg>
                </div>
              </div>
              
              <div class="content">
                ${V(this.convertNewlinesToParagraphs(this.content))}
              </div>
            </div>
          `:""}
        </div>
    `}};o.styles=u`
    .calculation-container {
      position: absolute;
      background: white;
      z-index: 3;
      right: 2.5rem;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      border: 1px solid #dbdbdb;
      border-radius: 3px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      padding: 0.5rem 0.5rem;
      background: #e5e7eb;
      align-items: center;
    }
    .content {
      font-size: 0.75rem;
      padding: 0.5rem 0.75rem;
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }
    .content p {
      margin: 0;
    }
    .header-title {
      font-weight: 600;
    }
    .icon {
      cursor: pointer;
    }
  `;c([g({type:String})],o.prototype,"content",2);c([f()],o.prototype,"visible",2);o=c([b("formula-component")],o);
