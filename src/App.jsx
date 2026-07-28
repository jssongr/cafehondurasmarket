import { useState, useEffect, useRef, useCallback } from "react";

// ─── PALETA ───────────────────────────────────────────────────────────────
const C = {
  marino:"#0F2942", marinoL:"#1E4468", naranja:"#EA580C", naranjaL:"#FB923C",
  ambar:"#F59E0B", ambarL:"#FDE68A", crema:"#F6F5F2", blanco:"#FFFFFF",
  gris:"#E7E9ED", grisM:"#8A93A3", texto:"#182233", rojo:"#C0392B",
  azul:"#1e40af", azulL:"#dbeafe", verde:"#166534", verdeL:"#dcfce7",
  amarillo:"#92400e", amarilloL:"#fef3c7", indigo:"#4338CA", indigoL:"#e0e7ff",
};

// ─── CSS GLOBAL ───────────────────────────────────────────────────────────
const CSS = `
@import url('https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Inter:wght@300;400;500;600;700&display=swap');
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Inter',sans-serif;background:${C.crema};color:${C.texto};font-size:14px}

/* AUTH */
.auth-bg{min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;
  background:linear-gradient(145deg,${C.marino} 0%,${C.marinoL} 55%,${C.naranja} 130%);position:relative;overflow:hidden}
.auth-deco{position:absolute;font-size:260px;opacity:.05;pointer-events:none}
.auth-deco.a{top:-80px;right:-80px;transform:rotate(15deg)}
.auth-deco.b{bottom:-100px;left:-60px;transform:rotate(-12deg)}
.auth-box{background:${C.blanco};border-radius:22px;width:100%;max-width:520px;
  box-shadow:0 24px 64px rgba(0,0,0,.38);overflow:hidden;position:relative;z-index:1}
.auth-top{background:linear-gradient(135deg,${C.marino},${C.marinoL});padding:28px 32px;text-align:center}
.auth-top h1{font-family:'Sora',sans-serif;font-size:25px;color:#fff;line-height:1.2}
.auth-top p{font-size:12px;color:rgba(255,255,255,.6);margin-top:4px}
.auth-body{padding:28px 32px;max-height:72vh;overflow-y:auto}
.tabs{display:flex;background:${C.gris};border-radius:10px;padding:3px;margin-bottom:22px}
.tab{flex:1;padding:9px;border:none;background:transparent;border-radius:8px;cursor:pointer;
  font-size:13px;font-weight:600;color:${C.grisM};transition:.2s;font-family:inherit}
.tab.on{background:${C.marino};color:#fff}
.field{margin-bottom:14px}
.field label{display:block;font-size:11px;font-weight:700;color:${C.naranja};margin-bottom:4px;
  text-transform:uppercase;letter-spacing:.5px}
.field input,.field select,.field textarea{width:100%;padding:10px 13px;border:1.5px solid ${C.gris};
  border-radius:10px;font-size:13px;background:${C.blanco};color:${C.texto};outline:none;
  transition:.2s;font-family:inherit}
.field input:focus,.field select:focus,.field textarea:focus{border-color:${C.ambar};
  box-shadow:0 0 0 3px rgba(245,158,11,.16)}
.field textarea{resize:vertical;min-height:72px}
.roles-grid{display:grid;grid-template-columns:1fr 1fr;gap:9px;margin-bottom:14px}
.role-opt{border:2px solid ${C.gris};border-radius:12px;padding:15px 8px;text-align:center;
  cursor:pointer;transition:.18s;background:${C.blanco}}
.role-opt:hover{border-color:${C.ambar}}
.role-opt.sel{border-color:${C.marino};background:#eef3f8}
.role-opt .ri{font-size:26px}
.role-opt .rn{font-size:12px;font-weight:700;color:${C.marino};margin-top:4px}
.role-opt .rd{font-size:10px;color:${C.grisM};margin-top:1px}
.err{background:#fef2f2;border:1px solid #fca5a5;color:${C.rojo};padding:9px 13px;
  border-radius:8px;font-size:12px;margin-bottom:12px}

/* VERIFICACIÓN ID */
.verif-steps{display:flex;gap:6px;margin-bottom:20px}
.vstep{flex:1;height:4px;border-radius:2px;background:${C.gris}}
.vstep.done{background:${C.marino}}
.vstep.active{background:${C.ambar}}
.upload-zone{border:2px dashed ${C.gris};border-radius:14px;padding:28px;text-align:center;
  cursor:pointer;transition:.2s;position:relative;background:#fafafa}
.upload-zone:hover{border-color:${C.ambar};background:#fffbf2}
.upload-zone input{position:absolute;inset:0;opacity:0;cursor:pointer}
.upload-zone .uz-icon{font-size:36px;margin-bottom:8px}
.upload-zone .uz-title{font-size:14px;font-weight:700;color:${C.marino}}
.upload-zone .uz-sub{font-size:11px;color:${C.grisM};margin-top:3px}
.preview-img{width:100%;max-height:200px;object-fit:cover;border-radius:10px;margin-top:10px}
.verif-check{display:flex;align-items:center;gap:10px;padding:12px;background:${C.verdeL};
  border-radius:10px;color:${C.verde};font-size:13px;font-weight:600;margin-top:10px}
.ai-scanning{display:flex;align-items:center;gap:10px;padding:12px;background:#f0f9ff;
  border-radius:10px;font-size:13px;color:${C.azul};margin-top:10px}
.spin{display:inline-block;animation:spin 1s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}

/* LAYOUT */
.layout{display:flex;min-height:100vh}
.sidebar{width:250px;background:${C.marino};min-height:100vh;display:flex;flex-direction:column;flex-shrink:0}
.sb-logo{padding:22px 18px 18px;border-bottom:1px solid rgba(255,255,255,.1)}
.sb-logo h2{font-family:'Sora',sans-serif;font-size:19px;color:#fff;line-height:1.25}
.sb-logo span{font-size:10px;color:rgba(255,255,255,.45)}
.sb-nav{flex:1;padding:14px 10px;overflow-y:auto}
.sb-sec{font-size:9px;color:rgba(255,255,255,.32);font-weight:700;text-transform:uppercase;
  letter-spacing:1.2px;padding:12px 10px 5px}
.sb-item{display:flex;align-items:center;gap:9px;padding:9px 11px;border-radius:10px;
  cursor:pointer;color:rgba(255,255,255,.68);font-size:13px;font-weight:500;
  transition:.15s;margin-bottom:1px;position:relative}
.sb-item:hover{background:rgba(255,255,255,.1);color:#fff}
.sb-item.on{background:${C.naranja};color:#fff;font-weight:700}
.sb-item .si{font-size:15px;width:20px;text-align:center}
.sb-badge{position:absolute;right:10px;top:50%;transform:translateY(-50%);
  background:#ef4444;color:#fff;border-radius:20px;font-size:10px;
  font-weight:700;padding:1px 7px;min-width:18px;text-align:center}
.sb-user{padding:14px;border-top:1px solid rgba(255,255,255,.1)}
.sb-chip{display:flex;align-items:center;gap:10px;padding:9px;
  background:rgba(255,255,255,.07);border-radius:10px}
.sb-av{width:38px;height:38px;border-radius:50%;background:${C.ambar};display:flex;
  align-items:center;justify-content:center;font-size:17px;flex-shrink:0;overflow:hidden}
.sb-av img{width:100%;height:100%;object-fit:cover}
.sb-uname{font-size:13px;font-weight:700;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.sb-urole{font-size:10px;color:rgba(255,255,255,.48)}
.sb-verif{font-size:9px;color:#4ade80;font-weight:600;margin-top:1px}
.sb-logout{width:100%;margin-top:7px;padding:7px;background:rgba(255,255,255,.07);
  border:none;border-radius:8px;color:rgba(255,255,255,.5);font-size:11px;cursor:pointer;
  font-family:inherit;transition:.15s}
.sb-logout:hover{background:rgba(255,255,255,.14);color:#fff}

/* CONTENT */
.main{flex:1;display:flex;flex-direction:column;overflow:hidden}
.topbar{background:${C.blanco};border-bottom:1px solid ${C.gris};padding:14px 26px;
  display:flex;align-items:center;justify-content:space-between;flex-shrink:0}
.topbar-left h1{font-family:'Sora',sans-serif;font-size:20px;color:${C.marino}}
.topbar-left p{font-size:12px;color:${C.grisM};margin-top:1px}
.topbar-right{display:flex;align-items:center;gap:10px}
.notif-btn{position:relative;background:none;border:none;cursor:pointer;font-size:20px;
  padding:6px;border-radius:8px;transition:.15s}
.notif-btn:hover{background:${C.gris}}
.notif-dot{position:absolute;top:4px;right:4px;width:8px;height:8px;
  background:#ef4444;border-radius:50%;border:2px solid ${C.blanco}}
.page{flex:1;overflow-y:auto;padding:24px}

/* CARDS & GRIDS */
.card{background:${C.blanco};border-radius:16px;padding:20px;box-shadow:0 2px 12px rgba(15,41,66,.06)}
.card-title{font-family:'Sora',sans-serif;font-size:16px;color:${C.marino};
  margin-bottom:14px;padding-bottom:10px;border-bottom:1px solid ${C.gris}}
.stats-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:22px}
.stat{background:${C.blanco};border-radius:14px;padding:18px;border-left:4px solid ${C.ambar};
  box-shadow:0 2px 10px rgba(15,41,66,.06)}
.stat .sl{font-size:11px;color:${C.grisM};font-weight:700;text-transform:uppercase;letter-spacing:.5px}
.stat .sv{font-family:'Sora',sans-serif;font-size:28px;color:${C.marino};margin:3px 0 2px}
.stat .ss{font-size:11px;color:${C.naranja}}
.two-col{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:22px}

/* MERCADO DE CARGAS */
.filter-row{background:${C.blanco};border-radius:14px;padding:16px;margin-bottom:18px;
  display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;box-shadow:0 2px 8px rgba(15,41,66,.05)}
.filter-row .field{margin:0;flex:1;min-width:140px}
.btn{padding:10px 20px;border:none;border-radius:10px;font-size:13px;font-weight:700;
  cursor:pointer;font-family:inherit;transition:.15s}
.btn-primary{background:linear-gradient(135deg,${C.marino},${C.marinoL});color:#fff}
.btn-primary:hover{transform:translateY(-1px);box-shadow:0 5px 16px rgba(15,41,66,.3)}
.btn-oro{background:${C.naranja};color:#fff}
.btn-oro:hover{background:${C.naranjaL}}
.btn-sm{padding:6px 13px;font-size:12px}
.btn-ghost{background:${C.gris};color:${C.texto}}
.btn-ghost:hover{background:#d8dce3}
.btn-danger{background:#fef2f2;color:${C.rojo}}
.btn-danger:hover{background:#fee2e2}
.listings-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px}
.lcard{background:${C.blanco};border-radius:16px;overflow:hidden;
  box-shadow:0 2px 12px rgba(15,41,66,.08);transition:.2s;cursor:pointer}
.lcard:hover{transform:translateY(-3px);box-shadow:0 10px 28px rgba(15,41,66,.15)}
.lcard-head{padding:18px;display:flex;align-items:center;gap:12px}
.lcard-head.publicada{background:linear-gradient(135deg,${C.marino},${C.marinoL})}
.lcard-head.asignada{background:linear-gradient(135deg,${C.ambar},${C.naranja})}
.lcard-head.en_transito{background:linear-gradient(135deg,${C.indigo},#6366f1)}
.lcard-head.entregada{background:linear-gradient(135deg,${C.verde},#22c55e)}
.lcard-head.cancelada{background:linear-gradient(135deg,#7f1d1d,${C.rojo})}
.lcard-head .lhi{font-size:30px}
.lcard-head .lht{font-size:10px;color:rgba(255,255,255,.65);text-transform:uppercase;letter-spacing:.8px}
.lcard-head .lhv{font-size:15px;font-weight:700;color:#fff;margin-top:2px}
.lcard-body{padding:16px}
.lrow{display:flex;justify-content:space-between;margin-bottom:8px;font-size:12px}
.lrow .lk{color:${C.grisM}} .lrow .lv{font-weight:600;color:${C.marino}}
.lruta{display:flex;align-items:center;gap:6px;font-size:12px;font-weight:700;color:${C.marino};
  background:${C.crema};border-radius:9px;padding:8px 10px;margin-bottom:10px}
.lprice{font-family:'Sora',sans-serif;font-size:20px;color:${C.naranja};margin:10px 0 6px}
.lprice span{font-size:11px;font-family:'Inter',sans-serif;color:${C.grisM};font-weight:400}
.badge{display:inline-block;padding:2px 9px;border-radius:20px;font-size:10px;font-weight:700}
.b-publicada{background:${C.azulL};color:${C.azul}}
.b-asignada{background:${C.amarilloL};color:${C.amarillo}}
.b-en_transito{background:${C.indigoL};color:${C.indigo}}
.b-entregada{background:${C.verdeL};color:${C.verde}}
.b-cancelada{background:#fef2f2;color:${C.rojo}}
.b-verif{background:${C.verdeL};color:${C.verde}}
.b-noVerif{background:#fef2f2;color:${C.rojo}}

/* MENSAJERÍA */
.msg-layout{display:grid;grid-template-columns:300px 1fr;gap:0;height:calc(100vh - 110px);
  background:${C.blanco};border-radius:16px;overflow:hidden;box-shadow:0 2px 12px rgba(15,41,66,.08)}
.convos{border-right:1px solid ${C.gris};overflow-y:auto}
.convos-head{padding:16px;border-bottom:1px solid ${C.gris};font-weight:700;color:${C.marino};
  font-size:15px;display:flex;align-items:center;justify-content:space-between}
.convo-item{padding:14px 16px;border-bottom:1px solid ${C.gris};cursor:pointer;transition:.15s}
.convo-item:hover{background:${C.crema}}
.convo-item.on{background:#eef3f8}
.ci-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:3px}
.ci-name{font-weight:700;font-size:13px;color:${C.marino}}
.ci-time{font-size:10px;color:${C.grisM}}
.ci-last{font-size:12px;color:${C.grisM};white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.ci-unread{background:#ef4444;color:#fff;border-radius:20px;font-size:10px;
  font-weight:700;padding:1px 6px;margin-left:6px}
.chat-area{display:flex;flex-direction:column;overflow:hidden}
.chat-head{padding:14px 18px;border-bottom:1px solid ${C.gris};display:flex;align-items:center;gap:12px}
.chat-head .ch-av{width:36px;height:36px;border-radius:50%;background:${C.gris};
  display:flex;align-items:center;justify-content:center;font-size:18px;overflow:hidden}
.chat-head .ch-av img{width:100%;height:100%;object-fit:cover}
.chat-head .ch-name{font-weight:700;color:${C.marino};font-size:14px}
.chat-head .ch-role{font-size:11px;color:${C.grisM}}
.messages{flex:1;overflow-y:auto;padding:16px;display:flex;flex-direction:column;gap:10px;background:#f9f9f7}
.msg{max-width:70%;padding:10px 14px;border-radius:14px;font-size:13px;line-height:1.5}
.msg.mine{align-self:flex-end;background:${C.marino};color:#fff;border-bottom-right-radius:4px}
.msg.theirs{align-self:flex-start;background:${C.blanco};color:${C.texto};
  border-bottom-left-radius:4px;box-shadow:0 1px 4px rgba(0,0,0,.08)}
.msg-time{font-size:10px;opacity:.6;margin-top:4px}
.msg-offer{background:${C.amarilloL};border:1.5px solid ${C.ambarL};border-radius:12px;
  padding:12px 14px;max-width:80%;align-self:flex-start}
.msg-offer.mine{align-self:flex-end;background:#eef3f8;border-color:${C.marinoL}}
.msg-offer .mo-label{font-size:10px;font-weight:700;color:${C.amarillo};text-transform:uppercase;margin-bottom:4px}
.msg-offer.mine .mo-label{color:${C.marino}}
.msg-offer .mo-price{font-family:'Sora',sans-serif;font-size:20px;color:${C.naranja}}
.msg-offer .mo-btns{display:flex;gap:8px;margin-top:8px}
.chat-input{padding:12px 16px;border-top:1px solid ${C.gris};display:flex;gap:8px;align-items:flex-end;background:${C.blanco}}
.chat-input textarea{flex:1;padding:9px 13px;border:1.5px solid ${C.gris};border-radius:10px;
  font-size:13px;font-family:inherit;resize:none;outline:none;min-height:40px;max-height:100px;transition:.2s}
.chat-input textarea:focus{border-color:${C.ambar};box-shadow:0 0 0 3px rgba(245,158,11,.12)}
.offer-bar{padding:10px 16px;background:${C.crema};border-top:1px solid ${C.gris};
  display:flex;gap:8px;align-items:center}
.offer-bar input{width:140px;padding:7px 11px;border:1.5px solid ${C.gris};border-radius:8px;
  font-size:13px;font-family:inherit;outline:none}
.offer-bar input:focus{border-color:${C.ambar}}

/* NOTIFICACIONES */
.notif-panel{position:fixed;top:60px;right:20px;width:340px;background:${C.blanco};
  border-radius:16px;box-shadow:0 10px 40px rgba(0,0,0,.2);z-index:200;overflow:hidden}
.np-head{padding:14px 18px;border-bottom:1px solid ${C.gris};display:flex;justify-content:space-between;align-items:center}
.np-head h3{font-weight:700;color:${C.marino};font-size:14px}
.np-list{max-height:400px;overflow-y:auto}
.notif-item{padding:13px 16px;border-bottom:1px solid ${C.gris};display:flex;gap:10px;
  cursor:pointer;transition:.15s}
.notif-item:hover{background:${C.crema}}
.notif-item.unread{background:#fffbf2}
.ni-icon{font-size:20px;flex-shrink:0;margin-top:1px}
.ni-body{flex:1}
.ni-title{font-size:13px;font-weight:600;color:${C.marino}}
.ni-sub{font-size:11px;color:${C.grisM};margin-top:2px}
.ni-time{font-size:10px;color:${C.grisM};margin-top:3px}

/* HISTORIAL */
.tx-list{display:flex;flex-direction:column;gap:12px}
.tx-item{background:${C.blanco};border-radius:14px;padding:16px 18px;
  display:flex;align-items:center;gap:14px;box-shadow:0 2px 8px rgba(15,41,66,.05)}
.tx-icon{width:44px;height:44px;border-radius:12px;background:${C.gris};
  display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0}
.tx-info{flex:1}
.tx-title{font-weight:700;color:${C.marino};font-size:14px}
.tx-sub{font-size:11px;color:${C.grisM};margin-top:2px}
.tx-price{text-align:right}
.tx-val{font-family:'Sora',sans-serif;font-size:18px;color:${C.naranja}}
.tx-date{font-size:10px;color:${C.grisM}}

/* PUBLICAR */
.pub-form{background:${C.blanco};border-radius:18px;padding:26px;max-width:680px;
  box-shadow:0 2px 14px rgba(15,41,66,.07)}
.fgrid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.fgrid .full{grid-column:1/-1}

/* PERFIL */
.profile-card{background:${C.blanco};border-radius:18px;padding:28px;max-width:580px;
  box-shadow:0 2px 14px rgba(15,41,66,.07)}
.profile-av{width:80px;height:80px;border-radius:50%;background:${C.gris};
  display:flex;align-items:center;justify-content:center;font-size:36px;
  margin:0 auto 16px;overflow:hidden;border:3px solid ${C.ambar}}
.profile-av img{width:100%;height:100%;object-fit:cover}

/* TOAST */
.toast{position:fixed;bottom:24px;right:24px;background:${C.marino};color:#fff;
  padding:12px 20px;border-radius:12px;font-size:13px;font-weight:600;z-index:999;
  box-shadow:0 8px 24px rgba(0,0,0,.22);animation:toastIn .3s ease;max-width:320px}
@keyframes toastIn{from{transform:translateY(16px);opacity:0}to{transform:translateY(0);opacity:1}}

/* MODAL */
.overlay{position:fixed;inset:0;background:rgba(0,0,0,.48);z-index:100;
  display:flex;align-items:center;justify-content:center;padding:20px}
.modal{background:${C.blanco};border-radius:20px;padding:28px;width:100%;max-width:520px;
  max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.3)}
.modal-hd{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:18px}
.modal-hd h2{font-family:'Sora',sans-serif;font-size:19px;color:${C.marino}}
.close-btn{background:none;border:none;font-size:20px;cursor:pointer;color:${C.grisM};padding:0 3px}
.irow{display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid ${C.gris};font-size:13px}
.irow:last-child{border:none}
.irow .ik{color:${C.grisM}} .irow .iv{font-weight:600;color:${C.marino}}
.contact-box{background:${C.crema};border-radius:12px;padding:14px;margin-top:14px}
.contact-box p{font-size:12px;font-weight:700;color:${C.naranja};margin-bottom:3px}

/* SEGUIMIENTO GPS */
.trk-card{background:${C.blanco};border-radius:16px;padding:20px;margin-bottom:16px;
  box-shadow:0 2px 12px rgba(15,41,66,.07)}
.trk-hd{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;flex-wrap:wrap;gap:8px}
.trk-title{font-weight:700;color:${C.marino};font-size:15px}
.trk-sub{font-size:11px;color:${C.grisM};margin-top:2px}
.corridor{position:relative;padding:26px 6px 30px}
.corridor-line{position:relative;height:6px;background:${C.gris};border-radius:4px}
.corridor-fill{position:absolute;top:0;left:0;height:6px;border-radius:4px;
  background:linear-gradient(90deg,${C.marino},${C.naranja});transition:width .6s ease}
.corridor-truck{position:absolute;top:50%;font-size:22px;transform:translate(-50%,-58%);transition:left .6s ease}
.corridor-ticks{position:relative;margin-top:8px}
.corridor-tick{position:absolute;top:0;transform:translateX(-50%);text-align:center;width:70px}
.corridor-tick .ct-dot{width:9px;height:9px;border-radius:50%;background:${C.gris};margin:0 auto 5px;border:2px solid ${C.blanco};box-shadow:0 0 0 1px ${C.gris}}
.corridor-tick.active .ct-dot{background:${C.naranja};box-shadow:0 0 0 1px ${C.naranja}}
.corridor-tick .ct-label{font-size:9px;color:${C.grisM};font-weight:600;line-height:1.2}
.corridor-tick.active .ct-label{color:${C.marino};font-weight:700}
.trk-meta{display:flex;gap:18px;flex-wrap:wrap;margin-top:10px}
.trk-meta .tm{font-size:11px;color:${C.grisM}}
.trk-meta .tm b{color:${C.marino};font-weight:700}

/* EMPTY */
.empty{text-align:center;padding:52px 20px;color:${C.grisM}}
.empty .ei{font-size:44px;margin-bottom:10px}
.empty p{font-size:14px} .empty small{font-size:12px;margin-top:4px;display:block}

/* RESPONSIVE */
@media(max-width:750px){
  .sidebar{display:none}.two-col{grid-template-columns:1fr}
  .msg-layout{grid-template-columns:1fr}.convos{display:none}
  .fgrid{grid-template-columns:1fr}.fgrid .full{grid-column:1}
  .corridor-tick{width:44px}
}
`;

// ─── DATOS INICIALES ──────────────────────────────────────────────────────
const PAISES = ["Panamá","Costa Rica","Nicaragua","Honduras","El Salvador","Guatemala","México"];
const PAIS_IDX = Object.fromEntries(PAISES.map((p,i)=>[p,i]));
const CIUDADES = {
  "Panamá":["Ciudad de Panamá","Colón","David"],
  "Costa Rica":["San José","Limón","Alajuela"],
  "Nicaragua":["Managua","León","Chinandega"],
  "Honduras":["Tegucigalpa","San Pedro Sula","Puerto Cortés"],
  "El Salvador":["San Salvador","Santa Ana","Acajutla"],
  "Guatemala":["Ciudad de Guatemala","Puerto Barrios","Quetzaltenango"],
  "México":["Tapachula","Ciudad de México","Veracruz"],
};

const TIPOS_CARGA = ["Carga general","Perecederos","Carga refrigerada","Contenedor 20'","Contenedor 40'",
  "Graneles","Maquinaria/Equipo","Materiales de construcción","Textiles","Electrónicos","Químicos (no peligrosos)"];
const TCI = {"Carga general":"📦","Perecederos":"🍌","Carga refrigerada":"🧊","Contenedor 20'":"🚢","Contenedor 40'":"🚢",
  "Graneles":"🌾","Maquinaria/Equipo":"⚙️","Materiales de construcción":"🧱","Textiles":"🧵","Electrónicos":"💻","Químicos (no peligrosos)":"🧪"};
const TIPOS_VEHICULO = ["Camión rabón (3-5 ton)","Furgón mediano","Cabezal + plataforma","Cabezal + rampla refrigerada (Reefer)","Cama baja (maquinaria)","Volteo"];

const CLIENTE_SUBTIPOS = ["Empresa importadora","Empresa exportadora","Fabricante","Distribuidor","Comercio","Operador logístico"];
const TRANSPORTISTA_SUBTIPOS = ["Transportista independiente","Empresa con flota de camiones"];

const TI = {cliente:"🏢", transportista:"🚚"};

const SEED_USERS = [
  {id:1,nombre:"Importadora del Istmo",email:"cliente@demo.com",password:"1234",tipo:"cliente",subtipo:"Empresa importadora",
   verificado:true,selfie:null,doc:null,telefono:"+(507) 6123-4567"},
  {id:2,nombre:"Carlos Rodríguez — Transportes CR",email:"transportista@demo.com",password:"1234",tipo:"transportista",
   subtipo:"Empresa con flota de camiones",vehiculo:"Cabezal + plataforma",capacidad:28,placa:"CR-4471",
   verificado:true,selfie:null,doc:null,telefono:"+(506) 8877-2345"},
];

const SEED_CARGAS = [
  {id:1,clienteId:1,cliente:"Importadora del Istmo",tipoCarga:"Contenedor 40'",peso:22,unidadPeso:"ton",
   paisOrigen:"Guatemala",ciudadOrigen:"Ciudad de Guatemala",paisDestino:"Honduras",ciudadDestino:"San Pedro Sula",
   fecha:"2026-08-02",vehiculoReq:"Cabezal + plataforma",presupuesto:1450,
   descripcion:"Repuestos industriales paletizados, requiere manejo cuidadoso.",
   estado:"publicada",transportistaId:null,transportistaNombre:null,precioAcordado:null,progreso:0,
   pago:{estado:"pendiente",monto:null},fechaAsignacion:null,fechaEntrega:null},
  {id:2,clienteId:1,cliente:"Importadora del Istmo",tipoCarga:"Carga refrigerada",peso:9,unidadPeso:"ton",
   paisOrigen:"Costa Rica",ciudadOrigen:"San José",paisDestino:"Panamá",ciudadDestino:"Ciudad de Panamá",
   fecha:"2026-07-25",vehiculoReq:"Cabezal + rampla refrigerada (Reefer)",presupuesto:980,
   descripcion:"Productos lácteos, requiere cadena de frío constante.",
   estado:"en_transito",transportistaId:2,transportistaNombre:"Carlos Rodríguez — Transportes CR",precioAcordado:980,
   progreso:42,pago:{estado:"retenido",monto:980},fechaAsignacion:"2026-07-24T09:00:00Z",fechaEntrega:null},
  {id:3,clienteId:1,cliente:"Importadora del Istmo",tipoCarga:"Materiales de construcción",peso:15,unidadPeso:"ton",
   paisOrigen:"Honduras",ciudadOrigen:"Tegucigalpa",paisDestino:"El Salvador",ciudadDestino:"San Salvador",
   fecha:"2026-07-10",vehiculoReq:"Volteo",presupuesto:640,
   descripcion:"Cemento y varilla, entrega puntual requerida.",
   estado:"entregada",transportistaId:2,transportistaNombre:"Carlos Rodríguez — Transportes CR",precioAcordado:640,
   progreso:100,pago:{estado:"liberado",monto:640},fechaAsignacion:"2026-07-08T09:00:00Z",fechaEntrega:"2026-07-10T18:20:00Z"},
];

const SEED_CONVOS = [
  {id:1,participantes:[1,2],cargaId:2,
   mensajes:[
     {id:1,de:2,texto:"Buenos días, tengo disponibilidad para su carga refrigerada CR→Panamá.",ts:"2026-07-23T14:00:00Z"},
     {id:2,de:1,texto:"Perfecto, ¿puede recoger el 24 en San José?",ts:"2026-07-23T14:05:00Z"},
     {id:3,de:2,tipo:"oferta",precio:980,ts:"2026-07-23T14:10:00Z",estado:"aceptada"},
   ]},
];

const SEED_NOTIFS = [
  {id:1,usuarioId:1,tipo:"mensaje",titulo:"Nuevo mensaje de Carlos Rodríguez",sub:"Disponibilidad para su carga refrigerada",ts:"2026-07-23T14:00:00Z",leida:false},
  {id:2,usuarioId:2,tipo:"sistema",titulo:"Carga asignada",sub:"CR → Panamá, salida 24 de julio",ts:"2026-07-23T14:12:00Z",leida:true},
];

const SEED_HIST = [
  {id:1,cargaId:3,clienteId:1,cliente:"Importadora del Istmo",transportistaId:2,
   transportista:"Carlos Rodríguez — Transportes CR",tipoCarga:"Materiales de construcción",
   ruta:"Tegucigalpa (Honduras) → San Salvador (El Salvador)",monto:640,fecha:"2026-07-10",estado:"completado"},
];

// ─── UTILS ────────────────────────────────────────────────────────────────
const fmtTime = (ts) => {
  const d = new Date(ts), now = new Date();
  const diff = (now - d) / 60000;
  if (diff < 1) return "ahora";
  if (diff < 60) return `${Math.floor(diff)}m`;
  if (diff < 1440) return `${Math.floor(diff/60)}h`;
  return d.toLocaleDateString("es-HN",{day:"2-digit",month:"short"});
};
const fmtMoneda = (n) => n==null ? "" : "$" + Number(n).toLocaleString();
const uid = () => Date.now() + Math.random();
const rand = (a,b) => Math.floor(Math.random()*(b-a+1))+a;

// ─── APP ──────────────────────────────────────────────────────────────────
export default function App() {
  const [usuarios, setUsuarios] = useState(SEED_USERS);
  const [usuario, setUsuario] = useState(null);
  const [vista, setVista] = useState("dashboard");
  const [cargas, setCargas] = useState(SEED_CARGAS);
  const [convos, setConvos] = useState(SEED_CONVOS);
  const [notifs, setNotifs] = useState(SEED_NOTIFS);
  const [historial, setHistorial] = useState(SEED_HIST);
  const [toast, setToast] = useState("");
  const [modalCarga, setModalCarga] = useState(null);
  const [showNotifs, setShowNotifs] = useState(false);

  const showToast = useCallback((msg) => {
    setToast(msg); setTimeout(()=>setToast(""), 3500);
  }, []);

  const addNotif = useCallback((uid2, tipo, titulo, sub) => {
    setNotifs(n => [{id:Date.now()+Math.random(),usuarioId:uid2,tipo,titulo,sub,ts:new Date().toISOString(),leida:false},...n]);
  }, []);

  // ── simulación de seguimiento GPS: avanza cargas "en_transito" y libera pago al llegar
  useEffect(()=>{
    const t = setInterval(()=>{
      setCargas(prev => {
        const entregadas = [];
        const next = prev.map(c=>{
          if(c.estado!=="en_transito") return c;
          const p = Math.min(100, c.progreso + rand(6,14));
          if(p>=100){
            const done = {...c,progreso:100,estado:"entregada",pago:{...c.pago,estado:"liberado"},fechaEntrega:new Date().toISOString()};
            entregadas.push(done);
            return done;
          }
          return {...c,progreso:p};
        });
        if(entregadas.length){
          setTimeout(()=>{
            entregadas.forEach(c=>{
              setHistorial(h=>[{id:uid(),cargaId:c.id,clienteId:c.clienteId,cliente:c.cliente,
                transportistaId:c.transportistaId,transportista:c.transportistaNombre,tipoCarga:c.tipoCarga,
                ruta:`${c.ciudadOrigen} (${c.paisOrigen}) → ${c.ciudadDestino} (${c.paisDestino})`,
                monto:c.precioAcordado,fecha:new Date().toISOString().split("T")[0],estado:"completado"},...h]);
              addNotif(c.clienteId,"sistema","✅ Carga entregada",`${c.tipoCarga} llegó a ${c.ciudadDestino}. Pago liberado al transportista.`);
              addNotif(c.transportistaId,"sistema","💰 Pago liberado",`Se liberó ${fmtMoneda(c.precioAcordado)} por la entrega de ${c.tipoCarga}.`);
            });
          },0);
        }
        return next;
      });
    },2600);
    return ()=>clearInterval(t);
  },[addNotif]);

  const asignarCarga = useCallback((cargaId, transportistaId, transportistaNombre, monto) => {
    setCargas(cs=>cs.map(c=>c.id===cargaId?{...c,estado:"asignada",transportistaId,transportistaNombre,
      precioAcordado:monto,pago:{estado:"retenido",monto},fechaAsignacion:new Date().toISOString()}:c));
  },[]);

  const iniciarViaje = useCallback((cargaId) => {
    setCargas(cs=>cs.map(c=>c.id===cargaId?{...c,estado:"en_transito",progreso:2}:c));
  },[]);

  const confirmarEntregaManual = useCallback((cargaId) => {
    setCargas(cs=>{
      const c = cs.find(x=>x.id===cargaId);
      if(!c) return cs;
      const done = {...c,progreso:100,estado:"entregada",pago:{...c.pago,estado:"liberado"},fechaEntrega:new Date().toISOString()};
      setTimeout(()=>{
        setHistorial(h=>[{id:uid(),cargaId:c.id,clienteId:c.clienteId,cliente:c.cliente,
          transportistaId:c.transportistaId,transportista:c.transportistaNombre,tipoCarga:c.tipoCarga,
          ruta:`${c.ciudadOrigen} (${c.paisOrigen}) → ${c.ciudadDestino} (${c.paisDestino})`,
          monto:c.precioAcordado,fecha:new Date().toISOString().split("T")[0],estado:"completado"},...h]);
        addNotif(c.clienteId,"sistema","✅ Carga entregada",`${c.tipoCarga} llegó a ${c.ciudadDestino}. Pago liberado al transportista.`);
        addNotif(c.transportistaId,"sistema","💰 Pago liberado",`Se liberó ${fmtMoneda(c.precioAcordado)} por la entrega de ${c.tipoCarga}.`);
      },0);
      return cs.map(x=>x.id===cargaId?done:x);
    });
  },[addNotif]);

  const unreadNotifs = notifs.filter(n=>n.usuarioId===usuario?.id && !n.leida).length;
  const unreadMsgs = convos.filter(c=>c.participantes.includes(usuario?.id) &&
    c.mensajes.some(m=>m.de!==usuario?.id && !m.leido)).length;

  const markNotifsRead = () => setNotifs(n=>n.map(x=>x.usuarioId===usuario?.id?{...x,leida:true}:x));

  if (!usuario) return (
    <div><style>{CSS}</style>
      <AuthScreen usuarios={usuarios} setUsuarios={setUsuarios}
        onLogin={u=>{setUsuario(u);setVista("dashboard");}} />
    </div>
  );

  const abrirOCrearConvo = (carga) => {
    const existe = convos.find(c=>c.participantes.includes(usuario.id)&&c.participantes.includes(usuario.tipo==="cliente"?carga.transportistaId:carga.clienteId)&&c.cargaId===carga.id);
    if(!existe){
      const otroId = usuario.tipo==="cliente" ? carga.transportistaId : carga.clienteId;
      if(otroId){
        setConvos(cs=>[...cs,{id:uid(),participantes:[usuario.id,otroId],cargaId:carga.id,mensajes:[]}]);
      } else {
        setConvos(cs=>[...cs,{id:uid(),participantes:[usuario.id,carga.clienteId],cargaId:carga.id,mensajes:[]}]);
      }
    }
    setVista("mensajes");
  };

  const aceptarViajeDirecto = (carga) => {
    asignarCarga(carga.id, usuario.id, usuario.nombre, carga.presupuesto);
    const existe = convos.find(c=>c.participantes.includes(usuario.id)&&c.participantes.includes(carga.clienteId)&&c.cargaId===carga.id);
    if(!existe) setConvos(cs=>[...cs,{id:uid(),participantes:[usuario.id,carga.clienteId],cargaId:carga.id,mensajes:[]}]);
    addNotif(carga.clienteId,"sistema","🚚 Viaje aceptado",`${usuario.nombre} aceptó transportar tu ${carga.tipoCarga}.`);
    showToast("¡Viaje aceptado! Coordina la recogida en Mensajes.");
    setVista("misviajes");
  };

  const NAV_CLIENTE = [
    {id:"dashboard",icon:"📊",label:"Panel Principal"},
    {id:"publicar",icon:"➕",label:"Publicar Carga"},
    {id:"miscargas",icon:"📋",label:"Mis Cargas"},
    {id:"seguimiento",icon:"📍",label:"Seguimiento GPS"},
    {id:"mensajes",icon:"💬",label:"Mensajes",badge:unreadMsgs},
    {id:"historial",icon:"📜",label:"Historial"},
    {id:"perfil",icon:"👤",label:"Mi Perfil"},
  ];
  const NAV_TRANSPORTISTA = [
    {id:"dashboard",icon:"📊",label:"Panel Principal"},
    {id:"disponibles",icon:"🏪",label:"Cargas Disponibles"},
    {id:"misviajes",icon:"🚚",label:"Mis Viajes"},
    {id:"seguimiento",icon:"📍",label:"Seguimiento GPS"},
    {id:"mensajes",icon:"💬",label:"Mensajes",badge:unreadMsgs},
    {id:"historial",icon:"📜",label:"Historial"},
    {id:"perfil",icon:"👤",label:"Mi Perfil"},
  ];

  return (
    <div>
      <style>{CSS}</style>
      <div className="layout">
        <Sidebar usuario={usuario} vista={vista} setVista={setVista}
          nav={usuario.tipo==="cliente"?NAV_CLIENTE:NAV_TRANSPORTISTA}
          onLogout={()=>{setUsuario(null);setVista("dashboard");}} />
        <div className="main">
          <TopBar vista={vista} usuario={usuario}
            unreadNotifs={unreadNotifs} showNotifs={showNotifs}
            setShowNotifs={(v)=>{setShowNotifs(v);if(v)markNotifsRead();}} />
          <div className="page">
            {vista==="dashboard" && <Dashboard usuario={usuario} cargas={cargas}
              historial={historial} notifs={notifs} setVista={setVista} />}
            {vista==="disponibles" && usuario.tipo==="transportista" && <CargasDisponibles cargas={cargas} usuario={usuario}
              usuarios={usuarios} onDetalle={setModalCarga}
              onAceptar={aceptarViajeDirecto}
              onCotizar={abrirOCrearConvo} />}
            {vista==="publicar" && usuario.tipo==="cliente" && <PublicarCarga usuario={usuario} setCargas={setCargas}
              showToast={showToast} />}
            {vista==="miscargas" && usuario.tipo==="cliente" && <MisCargas usuario={usuario} cargas={cargas}
              setCargas={setCargas} onDetalle={setModalCarga} showToast={showToast} setVista={setVista} />}
            {vista==="misviajes" && usuario.tipo==="transportista" && <MisViajes usuario={usuario} cargas={cargas}
              onDetalle={setModalCarga} iniciarViaje={iniciarViaje} confirmarEntregaManual={confirmarEntregaManual}
              setVista={setVista} showToast={showToast} />}
            {vista==="seguimiento" && <Seguimiento usuario={usuario} cargas={cargas}
              iniciarViaje={iniciarViaje} confirmarEntregaManual={confirmarEntregaManual} />}
            {vista==="mensajes" && <Mensajeria usuario={usuario} convos={convos}
              setConvos={setConvos} usuarios={usuarios} cargas={cargas}
              addNotif={addNotif} showToast={showToast} asignarCarga={asignarCarga} />}
            {vista==="historial" && <Historial usuario={usuario} historial={historial} />}
            {vista==="perfil" && <Perfil usuario={usuario} setUsuario={setUsuario}
              setUsuarios={setUsuarios} showToast={showToast} />}
          </div>
        </div>
      </div>
      {showNotifs && (
        <NotifPanel notifs={notifs.filter(n=>n.usuarioId===usuario.id)}
          onClose={()=>setShowNotifs(false)} setVista={setVista} />
      )}
      {modalCarga && <ModalCarga carga={modalCarga} onClose={()=>setModalCarga(null)}
        usuario={usuario} usuarios={usuarios}
        onContactar={()=>{ abrirOCrearConvo(modalCarga); setModalCarga(null); showToast("Chat abierto"); }} />}
      {toast && <div className="toast">✅ {toast}</div>}
    </div>
  );
}

// ─── AUTH SCREEN ──────────────────────────────────────────────────────────
function AuthScreen({usuarios, setUsuarios, onLogin}) {
  const [tab, setTab] = useState("login");
  const [step, setStep] = useState(1); // 1=datos, 2=documento, 3=selfie
  const [form, setForm] = useState({nombre:"",email:"",password:"",tipo:"",subtipo:"",telefono:"",
    vehiculo:TIPOS_VEHICULO[0],capacidad:"",placa:""});
  const [docImg, setDocImg] = useState(null);
  const [selfieImg, setSelfieImg] = useState(null);
  const [scanning, setScanning] = useState(false);
  const [scanned, setScanned] = useState(false);
  const [selfieScanning, setSelfieScanning] = useState(false);
  const [selfieOk, setSelfieOk] = useState(false);
  const [err, setErr] = useState("");
  const upd = (k,v) => setForm(f=>({...f,[k]:v}));

  const login = () => {
    const u = usuarios.find(u=>u.email===form.email&&u.password===form.password);
    if(!u) return setErr("Correo o contraseña incorrectos.");
    setErr(""); onLogin(u);
  };

  const handleDoc = (e) => {
    const file = e.target.files[0]; if(!file) return;
    const reader = new FileReader();
    reader.onload = ev => {
      setDocImg(ev.target.result);
      setScanning(true); setScanned(false);
      setTimeout(()=>{setScanning(false);setScanned(true);},2400);
    };
    reader.readAsDataURL(file);
  };

  const handleSelfie = (e) => {
    const file = e.target.files[0]; if(!file) return;
    const reader = new FileReader();
    reader.onload = ev => {
      setSelfieImg(ev.target.result);
      setSelfieScanning(true); setSelfieOk(false);
      setTimeout(()=>{setSelfieScanning(false);setSelfieOk(true);},2800);
    };
    reader.readAsDataURL(file);
  };

  const finalizarRegistro = () => {
    if(!selfieOk) return setErr("Completa la verificación facial.");
    const nuevo = {id:uid(),...form,capacidad:form.capacidad?+form.capacidad:null,
      verificado:true,selfie:selfieImg,doc:docImg};
    setUsuarios(us=>[...us,nuevo]); onLogin(nuevo);
  };

  const esTransportista = form.tipo==="transportista";
  const subtipos = esTransportista ? TRANSPORTISTA_SUBTIPOS : CLIENTE_SUBTIPOS;

  return (
    <div className="auth-bg">
      <div className="auth-deco a">🚚</div>
      <div className="auth-deco b">📦</div>
      <div className="auth-box">
        <div className="auth-top">
          <div style={{fontSize:36,marginBottom:8}}>🚛</div>
          <h1>CargaConecta</h1>
          <p>El transporte de carga terrestre de Panamá a México, en un solo lugar</p>
        </div>
        <div className="auth-body">
          <div className="tabs">
            <button className={`tab${tab==="login"?" on":""}`} onClick={()=>{setTab("login");setErr("");setStep(1);}}>Iniciar sesión</button>
            <button className={`tab${tab==="reg"?" on":""}`} onClick={()=>{setTab("reg");setErr("");setStep(1);}}>Crear cuenta</button>
          </div>
          {err && <div className="err">⚠️ {err}</div>}

          {tab==="login" ? (
            <>
              <div className="field"><label>Correo</label>
                <input type="email" placeholder="correo@ejemplo.com" value={form.email} onChange={e=>upd("email",e.target.value)} /></div>
              <div className="field"><label>Contraseña</label>
                <input type="password" placeholder="••••••" value={form.password} onChange={e=>upd("password",e.target.value)} /></div>
              <button className="btn btn-primary" style={{width:"100%",marginTop:4}} onClick={login}>Entrar a la plataforma</button>
              <p style={{textAlign:"center",fontSize:11,color:C.grisM,marginTop:10}}>Demo cliente: cliente@demo.com / 1234 · Demo transportista: transportista@demo.com / 1234</p>
            </>
          ) : (
            <>
              <div style={{display:"flex",gap:8,marginBottom:18,alignItems:"center"}}>
                {["Datos","Documento","Selfie"].map((s,i)=>(
                  <div key={i} style={{display:"flex",alignItems:"center",gap:4,flex:i<2?1:"auto"}}>
                    <div style={{width:24,height:24,borderRadius:"50%",background:step>i+1?C.marino:step===i+1?C.ambar:C.gris,
                      display:"flex",alignItems:"center",justifyContent:"center",fontSize:11,fontWeight:700,
                      color:step>=i+1?"#fff":C.grisM,flexShrink:0}}>
                      {step>i+1?"✓":i+1}
                    </div>
                    <span style={{fontSize:11,color:step===i+1?C.marino:C.grisM,fontWeight:step===i+1?700:400}}>{s}</span>
                    {i<2&&<div style={{flex:1,height:2,background:step>i+1?C.marino:C.gris,borderRadius:1,marginLeft:4}}/>}
                  </div>
                ))}
              </div>

              {step===1 && <>
                <div className="field"><label>Nombre completo o empresa</label>
                  <input placeholder="Ej. Transportes del Norte S.A." value={form.nombre} onChange={e=>upd("nombre",e.target.value)} /></div>
                <div className="field"><label>Correo electrónico</label>
                  <input type="email" placeholder="correo@ejemplo.com" value={form.email} onChange={e=>upd("email",e.target.value)} /></div>
                <div className="field"><label>Contraseña</label>
                  <input type="password" placeholder="Mínimo 6 caracteres" value={form.password} onChange={e=>upd("password",e.target.value)} /></div>
                <div className="field"><label>Teléfono</label>
                  <input placeholder="+(504) 9xxx-xxxx" value={form.telefono} onChange={e=>upd("telefono",e.target.value)} /></div>
                <div className="field"><label>¿Qué necesitas hacer?</label></div>
                <div className="roles-grid">
                  <div className={`role-opt${form.tipo==="cliente"?" sel":""}`} onClick={()=>upd("tipo","cliente")}>
                    <div className="ri">🏢</div><div className="rn">Cliente</div><div className="rd">Necesito transportar carga</div>
                  </div>
                  <div className={`role-opt${form.tipo==="transportista"?" sel":""}`} onClick={()=>upd("tipo","transportista")}>
                    <div className="ri">🚚</div><div className="rn">Transportista</div><div className="rd">Tengo camión disponible</div>
                  </div>
                </div>
                {form.tipo && <div className="field"><label>{esTransportista?"Tipo de transportista":"Tipo de empresa"}</label>
                  <select value={form.subtipo} onChange={e=>upd("subtipo",e.target.value)}>
                    <option value="">Selecciona…</option>
                    {subtipos.map(s=><option key={s}>{s}</option>)}
                  </select></div>}
                {esTransportista && <div className="fgrid">
                  <div className="field"><label>Tipo de vehículo</label>
                    <select value={form.vehiculo} onChange={e=>upd("vehiculo",e.target.value)}>
                      {TIPOS_VEHICULO.map(v=><option key={v}>{v}</option>)}</select></div>
                  <div className="field"><label>Capacidad (toneladas)</label>
                    <input type="number" placeholder="28" value={form.capacidad} onChange={e=>upd("capacidad",e.target.value)} /></div>
                  <div className="field full"><label>Placa del vehículo</label>
                    <input placeholder="Ej. HN-1234" value={form.placa} onChange={e=>upd("placa",e.target.value)} /></div>
                </div>}
                <button className="btn btn-primary" style={{width:"100%"}} onClick={()=>{
                  if(!form.nombre||!form.email||!form.password||!form.tipo||!form.subtipo||!form.telefono) return setErr("Completa todos los campos.");
                  if(esTransportista&&!form.capacidad) return setErr("Indica la capacidad del vehículo.");
                  if(usuarios.find(u=>u.email===form.email)) return setErr("Este correo ya está registrado.");
                  setErr(""); setStep(2);
                }}>Siguiente →</button>
              </>}

              {step===2 && <>
                <div style={{marginBottom:14}}>
                  <p style={{fontSize:13,color:C.marino,fontWeight:700,marginBottom:4}}>
                    {esTransportista?"🪪 Licencia de conducir vigente":"📋 Documento de la empresa (RTN / Registro mercantil)"}
                  </p>
                  <p style={{fontSize:12,color:C.grisM}}>
                    {esTransportista
                      ? "Sube una foto clara de tu licencia de conducir. Esto nos ayuda a verificar tu identidad como transportista."
                      : "Sube una foto o escaneo de tu documento de registro comercial para verificar tu empresa."}
                  </p>
                </div>
                <div className="upload-zone">
                  <input type="file" accept="image/*" onChange={handleDoc} />
                  <div className="uz-icon">{docImg?"📄":esTransportista?"🪪":"📋"}</div>
                  <div className="uz-title">{docImg?"Documento cargado":"Subir documento"}</div>
                  <div className="uz-sub">Haz clic o arrastra tu imagen aquí</div>
                  {docImg && <img src={docImg} className="preview-img" alt="documento" />}
                </div>
                {scanning && <div className="ai-scanning"><span className="spin">⚙️</span> Leyendo datos del documento con IA…</div>}
                {scanned && <div className="verif-check">✅ Documento verificado correctamente — datos extraídos</div>}
                <div style={{display:"flex",gap:8,marginTop:14}}>
                  <button className="btn btn-ghost" style={{flex:1}} onClick={()=>setStep(1)}>← Atrás</button>
                  <button className="btn btn-primary" style={{flex:2}} onClick={()=>{
                    if(!scanned) return setErr("Sube tu documento para continuar.");
                    setErr(""); setStep(3);
                  }}>Siguiente →</button>
                </div>
              </>}

              {step===3 && <>
                <div style={{marginBottom:14}}>
                  <p style={{fontSize:13,color:C.marino,fontWeight:700,marginBottom:4}}>🤳 Selfie para reconocimiento facial</p>
                  <p style={{fontSize:12,color:C.grisM}}>Tómate una selfie clara mirando de frente. Nuestra IA la comparará con tu documento para confirmar tu identidad.</p>
                </div>
                <div className="upload-zone">
                  <input type="file" accept="image/*" onChange={handleSelfie} />
                  <div className="uz-icon">{selfieImg?"🤳":"📸"}</div>
                  <div className="uz-title">{selfieImg?"Selfie cargada":"Subir selfie"}</div>
                  <div className="uz-sub">Haz clic o arrastra tu foto aquí</div>
                  {selfieImg && <img src={selfieImg} className="preview-img" alt="selfie" />}
                </div>
                {selfieScanning && <div className="ai-scanning"><span className="spin">🧠</span> Comparando rostro con documento mediante IA…</div>}
                {selfieOk && <div className="verif-check">✅ ¡Identidad verificada! Coincidencia facial confirmada</div>}
                <div style={{display:"flex",gap:8,marginTop:14}}>
                  <button className="btn btn-ghost" style={{flex:1}} onClick={()=>setStep(2)}>← Atrás</button>
                  <button onClick={finalizarRegistro} disabled={!selfieOk} style={{flex:2,opacity:selfieOk?1:.5,
                    background:`linear-gradient(135deg,${C.marino},${C.marinoL})`,color:"#fff",
                    border:"none",borderRadius:10,padding:"10px 20px",fontSize:13,fontWeight:700,cursor:selfieOk?"pointer":"not-allowed",fontFamily:"inherit"}}>
                    ✅ Crear cuenta verificada
                  </button>
                </div>
              </>}
            </>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── SIDEBAR ──────────────────────────────────────────────────────────────
function Sidebar({usuario, vista, setVista, nav, onLogout}) {
  return (
    <div className="sidebar">
      <div className="sb-logo">
        <h2>🚛 Carga<br/>Conecta</h2>
        <span>Panamá — México</span>
      </div>
      <nav className="sb-nav">
        <div className="sb-sec">Navegación</div>
        {nav.map(n=>(
          <div key={n.id} className={`sb-item${vista===n.id?" on":""}`} onClick={()=>setVista(n.id)}>
            <span className="si">{n.icon}</span>{n.label}
            {n.badge>0 && <span className="sb-badge">{n.badge}</span>}
          </div>
        ))}
      </nav>
      <div className="sb-user">
        <div className="sb-chip">
          <div className="sb-av">
            {usuario.selfie?<img src={usuario.selfie} alt="av"/>:TI[usuario.tipo]}
          </div>
          <div style={{flex:1,minWidth:0}}>
            <div className="sb-uname">{usuario.nombre}</div>
            <div className="sb-urole">{usuario.subtipo}</div>
            {usuario.verificado && <div className="sb-verif">✅ Verificado</div>}
          </div>
        </div>
        <button className="sb-logout" onClick={onLogout}>⬅ Cerrar sesión</button>
      </div>
    </div>
  );
}

// ─── TOPBAR ───────────────────────────────────────────────────────────────
const VISTA_LABELS = {
  dashboard:"Panel Principal",disponibles:"Cargas Disponibles",publicar:"Publicar Carga",
  miscargas:"Mis Cargas",misviajes:"Mis Viajes",seguimiento:"Seguimiento GPS",
  mensajes:"Mensajes",historial:"Historial de Viajes",perfil:"Mi Perfil"
};
function TopBar({vista, usuario, unreadNotifs, showNotifs, setShowNotifs}) {
  return (
    <div className="topbar">
      <div className="topbar-left">
        <h1>{VISTA_LABELS[vista]||vista}</h1>
        <p>CargaConecta — {usuario.subtipo}</p>
      </div>
      <div className="topbar-right">
        <button className="notif-btn" onClick={()=>setShowNotifs(!showNotifs)}>
          🔔{unreadNotifs>0&&<span className="notif-dot"/>}
        </button>
      </div>
    </div>
  );
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────
function Dashboard({usuario, cargas, historial, notifs, setVista}) {
  const unread = notifs.filter(n=>n.usuarioId===usuario.id&&!n.leida).length;
  const misNotifs = notifs.filter(n=>n.usuarioId===usuario.id);

  if(usuario.tipo==="cliente"){
    const mias = cargas.filter(c=>c.clienteId===usuario.id);
    const activas = mias.filter(c=>["publicada","asignada","en_transito"].includes(c.estado));
    const enTransito = mias.filter(c=>c.estado==="en_transito");
    const entregadas = mias.filter(c=>c.estado==="entregada");
    return (
      <>
        <div className="stats-row">
          <div className="stat"><div className="sl">Cargas activas</div>
            <div className="sv">{activas.length}</div><div className="ss">📦 en proceso</div></div>
          <div className="stat" style={{borderLeftColor:C.indigo}}>
            <div className="sl">En tránsito</div><div className="sv">{enTransito.length}</div>
            <div className="ss">🚚 en camino ahora</div></div>
          <div className="stat" style={{borderLeftColor:C.verde}}>
            <div className="sl">Entregadas</div><div className="sv">{entregadas.length}</div>
            <div className="ss">✅ completadas</div></div>
          <div className="stat" style={{borderLeftColor:"#6366f1"}}>
            <div className="sl">Notificaciones</div><div className="sv">{unread}</div>
            <div className="ss">🔔 sin leer</div></div>
        </div>
        <div className="two-col">
          <div className="card">
            <div className="card-title">Mis cargas recientes</div>
            {mias.length===0&&<div className="empty" style={{padding:"20px 0"}}><div className="ei">📦</div><p>Aún no has publicado cargas</p></div>}
            {mias.slice(-5).reverse().map(c=>(
              <div key={c.id} style={{display:"flex",justifyContent:"space-between",alignItems:"center",
                padding:"9px 0",borderBottom:`1px solid ${C.gris}`,fontSize:12}}>
                <div><span style={{marginRight:5}}>{TCI[c.tipoCarga]}</span>
                  <strong>{c.tipoCarga}</strong><span style={{color:C.grisM,marginLeft:5}}>· {c.paisOrigen} → {c.paisDestino}</span></div>
                <span className={`badge b-${c.estado}`}>{c.estado.replace("_"," ")}</span>
              </div>
            ))}
          </div>
          <div className="card">
            <div className="card-title">Actividad reciente</div>
            {misNotifs.slice(0,5).map(n=>(
              <div key={n.id} style={{display:"flex",gap:10,padding:"9px 0",borderBottom:`1px solid ${C.gris}`}}>
                <span style={{fontSize:18}}>{n.tipo==="mensaje"?"💬":n.tipo==="oferta"?"💰":"📢"}</span>
                <div>
                  <div style={{fontSize:12,fontWeight:700,color:C.marino}}>{n.titulo}</div>
                  <div style={{fontSize:11,color:C.grisM}}>{n.sub}</div>
                  <div style={{fontSize:10,color:C.grisM,marginTop:2}}>{fmtTime(n.ts)}</div>
                </div>
              </div>
            ))}
            {misNotifs.length===0&&<div className="empty"><div className="ei">🔔</div><p>Sin actividad reciente</p></div>}
          </div>
        </div>
      </>
    );
  }

  // transportista
  const disponibles = cargas.filter(c=>c.estado==="publicada");
  const misViajes = cargas.filter(c=>c.transportistaId===usuario.id&&["asignada","en_transito"].includes(c.estado));
  const misHist = historial.filter(h=>h.transportistaId===usuario.id);
  const ingresos = misHist.reduce((a,h)=>a+h.monto,0);
  return (
    <>
      <div className="stats-row">
        <div className="stat"><div className="sl">Cargas disponibles</div>
          <div className="sv">{disponibles.length}</div><div className="ss">🏪 en el corredor</div></div>
        <div className="stat" style={{borderLeftColor:C.indigo}}>
          <div className="sl">Mis viajes activos</div><div className="sv">{misViajes.length}</div>
          <div className="ss">🚚 en curso</div></div>
        <div className="stat" style={{borderLeftColor:C.verde}}>
          <div className="sl">Viajes completados</div><div className="sv">{misHist.length}</div>
          <div className="ss">✅ entregados</div></div>
        <div className="stat" style={{borderLeftColor:"#6366f1"}}>
          <div className="sl">Ingresos totales</div><div className="sv">{fmtMoneda(ingresos)}</div>
          <div className="ss">💰 histórico</div></div>
      </div>
      <div className="two-col">
        <div className="card">
          <div className="card-title">Últimas cargas publicadas</div>
          {disponibles.length===0&&<div className="empty" style={{padding:"20px 0"}}><div className="ei">🏪</div><p>No hay cargas disponibles ahora</p></div>}
          {disponibles.slice(-5).reverse().map(c=>(
            <div key={c.id} style={{display:"flex",justifyContent:"space-between",alignItems:"center",
              padding:"9px 0",borderBottom:`1px solid ${C.gris}`,fontSize:12}}>
              <div><span style={{marginRight:5}}>{TCI[c.tipoCarga]}</span>
                <strong>{c.tipoCarga}</strong><span style={{color:C.grisM,marginLeft:5}}>· {c.paisOrigen} → {c.paisDestino}</span></div>
              <div style={{fontWeight:700,color:C.naranja}}>{c.presupuesto?fmtMoneda(c.presupuesto):"Cotizar"}</div>
            </div>
          ))}
          <button className="btn btn-sm btn-ghost" style={{marginTop:10}} onClick={()=>setVista("disponibles")}>Ver todas →</button>
        </div>
        <div className="card">
          <div className="card-title">Actividad reciente</div>
          {misNotifs.slice(0,5).map(n=>(
            <div key={n.id} style={{display:"flex",gap:10,padding:"9px 0",borderBottom:`1px solid ${C.gris}`}}>
              <span style={{fontSize:18}}>{n.tipo==="mensaje"?"💬":n.tipo==="oferta"?"💰":"📢"}</span>
              <div>
                <div style={{fontSize:12,fontWeight:700,color:C.marino}}>{n.titulo}</div>
                <div style={{fontSize:11,color:C.grisM}}>{n.sub}</div>
                <div style={{fontSize:10,color:C.grisM,marginTop:2}}>{fmtTime(n.ts)}</div>
              </div>
            </div>
          ))}
          {misNotifs.length===0&&<div className="empty"><div className="ei">🔔</div><p>Sin actividad reciente</p></div>}
        </div>
      </div>
    </>
  );
}

// ─── CARGAS DISPONIBLES (marketplace del transportista) ───────────────────
function CargasDisponibles({cargas, usuario, usuarios, onDetalle, onAceptar, onCotizar}) {
  const [f, setF] = useState({paisOrigen:"",paisDestino:"",tipoCarga:"",buscar:""});
  const upd = (k,v)=>setF(x=>({...x,[k]:v}));
  const res = cargas.filter(c=>{
    if(c.estado!=="publicada") return false;
    if(f.paisOrigen&&c.paisOrigen!==f.paisOrigen) return false;
    if(f.paisDestino&&c.paisDestino!==f.paisDestino) return false;
    if(f.tipoCarga&&c.tipoCarga!==f.tipoCarga) return false;
    if(f.buscar&&!c.cliente.toLowerCase().includes(f.buscar.toLowerCase())&&
       !c.tipoCarga.toLowerCase().includes(f.buscar.toLowerCase())) return false;
    return true;
  });
  const getU = (uid2) => usuarios.find(u=>u.id===uid2);
  return (
    <>
      <div className="filter-row">
        <div className="field" style={{minWidth:140}}><label>Origen</label>
          <select value={f.paisOrigen} onChange={e=>upd("paisOrigen",e.target.value)}>
            <option value="">Todos</option>{PAISES.map(p=><option key={p}>{p}</option>)}
          </select></div>
        <div className="field" style={{minWidth:140}}><label>Destino</label>
          <select value={f.paisDestino} onChange={e=>upd("paisDestino",e.target.value)}>
            <option value="">Todos</option>{PAISES.map(p=><option key={p}>{p}</option>)}
          </select></div>
        <div className="field" style={{minWidth:160}}><label>Tipo de carga</label>
          <select value={f.tipoCarga} onChange={e=>upd("tipoCarga",e.target.value)}>
            <option value="">Todos</option>{TIPOS_CARGA.map(t=><option key={t}>{t}</option>)}
          </select></div>
        <div className="field" style={{flex:2}}><label>Buscar</label>
          <input placeholder="Cliente, tipo de carga…" value={f.buscar} onChange={e=>upd("buscar",e.target.value)} /></div>
      </div>
      {res.length===0&&<div className="empty"><div className="ei">🔍</div>
        <p>Sin cargas disponibles con esos filtros</p></div>}
      <div className="listings-grid">
        {res.map(c=>{
          const pub = getU(c.clienteId);
          return (
            <div className="lcard" key={c.id}>
              <div className={`lcard-head ${c.estado}`} onClick={()=>onDetalle(c)}>
                <span className="lhi">{TCI[c.tipoCarga]}</span>
                <div>
                  <div className="lht">{c.peso} {c.unidadPeso} · <span className={`badge b-${c.estado}`}>{c.estado}</span></div>
                  <div className="lhv">{c.tipoCarga}</div>
                </div>
              </div>
              <div className="lcard-body">
                <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:10}}>
                  <div style={{width:28,height:28,borderRadius:"50%",background:C.gris,
                    display:"flex",alignItems:"center",justifyContent:"center",fontSize:14,overflow:"hidden",flexShrink:0}}>
                    {pub?.selfie?<img src={pub.selfie} style={{width:"100%",height:"100%",objectFit:"cover"}} alt="av"/>:"🏢"}
                  </div>
                  <div>
                    <div style={{fontSize:12,fontWeight:700,color:C.marino}}>{c.cliente}</div>
                    <span className={`badge ${pub?.verificado?"b-verif":"b-noVerif"}`}>
                      {pub?.verificado?"✅ Verificado":"⚠️ Sin verificar"}</span>
                  </div>
                </div>
                <div className="lruta">📍 {c.ciudadOrigen}, {c.paisOrigen} <span style={{color:C.naranja}}>→</span> {c.ciudadDestino}, {c.paisDestino}</div>
                <div className="lrow"><span className="lk">Vehículo requerido</span><span className="lv">{c.vehiculoReq}</span></div>
                <div className="lrow"><span className="lk">Fecha de recogida</span><span className="lv">{c.fecha}</span></div>
                <div className="lprice">{c.presupuesto?fmtMoneda(c.presupuesto):"Abierto a cotización"}</div>
                <div style={{display:"flex",gap:7}}>
                  {c.presupuesto && (
                    <button className="btn btn-sm btn-primary" style={{flex:1}} onClick={()=>onAceptar(c)}>🚚 Aceptar viaje</button>
                  )}
                  <button className="btn btn-sm btn-oro" style={{flex:1}} onClick={()=>onCotizar(c)}>💰 Cotizar</button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </>
  );
}

// ─── PUBLICAR CARGA ─────────────────────────────────────────────────────────
function PublicarCarga({usuario, setCargas, showToast}) {
  const [f, setF] = useState({tipoCarga:TIPOS_CARGA[0],peso:"",unidadPeso:"ton",
    paisOrigen:PAISES[0],ciudadOrigen:CIUDADES[PAISES[0]][0],paisDestino:PAISES[1],ciudadDestino:CIUDADES[PAISES[1]][0],
    fecha:"",vehiculoReq:TIPOS_VEHICULO[0],presupuestoAbierto:false,presupuesto:"",descripcion:""});
  const upd = (k,v)=>setF(x=>({...x,[k]:v}));

  const submit = () => {
    if(!f.peso||!f.fecha) return alert("Peso y fecha de recogida son obligatorios.");
    if(!f.presupuestoAbierto&&!f.presupuesto) return alert("Indica un presupuesto o marca 'Abierto a cotizaciones'.");
    const nueva = {id:uid(),clienteId:usuario.id,cliente:usuario.nombre,
      tipoCarga:f.tipoCarga,peso:+f.peso,unidadPeso:f.unidadPeso,
      paisOrigen:f.paisOrigen,ciudadOrigen:f.ciudadOrigen,paisDestino:f.paisDestino,ciudadDestino:f.ciudadDestino,
      fecha:f.fecha,vehiculoReq:f.vehiculoReq,presupuesto:f.presupuestoAbierto?null:+f.presupuesto,
      descripcion:f.descripcion,estado:"publicada",transportistaId:null,transportistaNombre:null,
      precioAcordado:null,progreso:0,pago:{estado:"pendiente",monto:null},fechaAsignacion:null,fechaEntrega:null};
    setCargas(cs=>[...cs,nueva]);
    showToast("¡Carga publicada! Los transportistas ya pueden verla.");
    setF(x=>({...x,peso:"",fecha:"",presupuesto:"",descripcion:""}));
  };

  return (
    <div className="pub-form">
      <div style={{fontFamily:"'Sora',sans-serif",fontSize:18,color:C.marino,marginBottom:18}}>Publicar nueva carga</div>
      <div className="fgrid">
        <div className="field"><label>Tipo de mercancía *</label>
          <select value={f.tipoCarga} onChange={e=>upd("tipoCarga",e.target.value)}>
            {TIPOS_CARGA.map(t=><option key={t}>{t}</option>)}</select></div>
        <div className="field"><label>Vehículo requerido *</label>
          <select value={f.vehiculoReq} onChange={e=>upd("vehiculoReq",e.target.value)}>
            {TIPOS_VEHICULO.map(v=><option key={v}>{v}</option>)}</select></div>
        <div className="field"><label>Peso *</label>
          <input type="number" placeholder="15" value={f.peso} onChange={e=>upd("peso",e.target.value)} /></div>
        <div className="field"><label>Unidad</label>
          <select value={f.unidadPeso} onChange={e=>upd("unidadPeso",e.target.value)}>
            <option value="ton">Toneladas</option><option value="kg">Kilogramos</option></select></div>
        <div className="field"><label>País de origen *</label>
          <select value={f.paisOrigen} onChange={e=>{upd("paisOrigen",e.target.value);upd("ciudadOrigen",CIUDADES[e.target.value][0]);}}>
            {PAISES.map(p=><option key={p}>{p}</option>)}</select></div>
        <div className="field"><label>Ciudad de origen *</label>
          <select value={f.ciudadOrigen} onChange={e=>upd("ciudadOrigen",e.target.value)}>
            {CIUDADES[f.paisOrigen].map(c=><option key={c}>{c}</option>)}</select></div>
        <div className="field"><label>País de destino *</label>
          <select value={f.paisDestino} onChange={e=>{upd("paisDestino",e.target.value);upd("ciudadDestino",CIUDADES[e.target.value][0]);}}>
            {PAISES.map(p=><option key={p}>{p}</option>)}</select></div>
        <div className="field"><label>Ciudad de destino *</label>
          <select value={f.ciudadDestino} onChange={e=>upd("ciudadDestino",e.target.value)}>
            {CIUDADES[f.paisDestino].map(c=><option key={c}>{c}</option>)}</select></div>
        <div className="field"><label>Fecha de recogida *</label>
          <input type="date" value={f.fecha} onChange={e=>upd("fecha",e.target.value)} /></div>
        <div className="field">
          <label>Presupuesto (USD)</label>
          <input type="number" placeholder="1200" disabled={f.presupuestoAbierto}
            style={f.presupuestoAbierto?{opacity:.5}:{}}
            value={f.presupuesto} onChange={e=>upd("presupuesto",e.target.value)} />
          <label style={{display:"flex",alignItems:"center",gap:6,marginTop:6,textTransform:"none",fontWeight:500,color:C.grisM,fontSize:11}}>
            <input type="checkbox" style={{width:"auto"}} checked={f.presupuestoAbierto}
              onChange={e=>upd("presupuestoAbierto",e.target.checked)} /> Abierto a cotizaciones (sin precio fijo)
          </label>
        </div>
        <div className="field full"><label>Descripción</label>
          <textarea placeholder="Detalles de la carga, condiciones de manejo, etc." value={f.descripcion}
            onChange={e=>upd("descripcion",e.target.value)} /></div>
      </div>
      <button className="btn btn-primary" style={{marginTop:4}} onClick={submit}>🚀 Publicar carga</button>
    </div>
  );
}

// ─── MIS CARGAS (cliente) ──────────────────────────────────────────────────
function MisCargas({usuario, cargas, setCargas, onDetalle, showToast, setVista}) {
  const mias = cargas.filter(c=>c.clienteId===usuario.id);
  const cancelar = (id) => { setCargas(cs=>cs.map(c=>c.id===id?{...c,estado:"cancelada"}:c)); showToast("Publicación cancelada"); };
  return (
    <>
      {mias.length===0&&<div className="empty"><div className="ei">📝</div>
        <p>No tienes cargas publicadas</p><small>Crea tu primera en "Publicar Carga"</small></div>}
      <div style={{display:"flex",flexDirection:"column",gap:12}}>
        {mias.map(c=>(
          <div key={c.id} style={{background:C.blanco,borderRadius:14,padding:"16px 18px",
            display:"flex",alignItems:"center",gap:14,boxShadow:"0 2px 8px rgba(15,41,66,.05)",flexWrap:"wrap"}}>
            <div style={{width:46,height:46,borderRadius:12,background:C.gris,display:"flex",
              alignItems:"center",justifyContent:"center",fontSize:22,flexShrink:0}}>{TCI[c.tipoCarga]}</div>
            <div style={{flex:1,minWidth:200}}>
              <div style={{fontWeight:700,color:C.marino,fontSize:14}}>{c.tipoCarga} · {c.peso} {c.unidadPeso}</div>
              <div style={{fontSize:11,color:C.grisM,marginTop:2}}>{c.ciudadOrigen} → {c.ciudadDestino} · <span className={`badge b-${c.estado}`}>{c.estado.replace("_"," ")}</span></div>
              {c.transportistaNombre&&<div style={{fontSize:11,color:C.grisM,marginTop:3}}>🚚 {c.transportistaNombre}</div>}
              <div style={{display:"flex",gap:7,marginTop:7,flexWrap:"wrap"}}>
                <button className="btn btn-sm btn-ghost" onClick={()=>onDetalle(c)}>👁 Ver</button>
                {c.estado==="publicada"&&<button className="btn btn-sm btn-danger" onClick={()=>cancelar(c.id)}>🗑 Cancelar</button>}
                {["asignada","en_transito"].includes(c.estado)&&<button className="btn btn-sm btn-oro" onClick={()=>setVista("seguimiento")}>📍 Ver seguimiento</button>}
              </div>
            </div>
            <div style={{textAlign:"right",flexShrink:0}}>
              <div style={{fontFamily:"'Sora',sans-serif",fontSize:19,color:C.naranja}}>{c.precioAcordado?fmtMoneda(c.precioAcordado):(c.presupuesto?fmtMoneda(c.presupuesto):"Cotización")}</div>
              {c.pago.estado!=="pendiente"&&<div style={{fontSize:10,color:C.grisM}}>Pago {c.pago.estado}</div>}
            </div>
          </div>
        ))}
      </div>
    </>
  );
}

// ─── MIS VIAJES (transportista) ────────────────────────────────────────────
function MisViajes({usuario, cargas, onDetalle, iniciarViaje, confirmarEntregaManual, setVista, showToast}) {
  const mios = cargas.filter(c=>c.transportistaId===usuario.id);
  return (
    <>
      {mios.length===0&&<div className="empty"><div className="ei">🚚</div>
        <p>Aún no tienes viajes asignados</p><small>Acepta o cotiza una carga en "Cargas Disponibles"</small></div>}
      <div style={{display:"flex",flexDirection:"column",gap:12}}>
        {mios.map(c=>(
          <div key={c.id} style={{background:C.blanco,borderRadius:14,padding:"16px 18px",
            display:"flex",alignItems:"center",gap:14,boxShadow:"0 2px 8px rgba(15,41,66,.05)",flexWrap:"wrap"}}>
            <div style={{width:46,height:46,borderRadius:12,background:C.gris,display:"flex",
              alignItems:"center",justifyContent:"center",fontSize:22,flexShrink:0}}>{TCI[c.tipoCarga]}</div>
            <div style={{flex:1,minWidth:200}}>
              <div style={{fontWeight:700,color:C.marino,fontSize:14}}>{c.tipoCarga} · {c.peso} {c.unidadPeso}</div>
              <div style={{fontSize:11,color:C.grisM,marginTop:2}}>{c.ciudadOrigen} → {c.ciudadDestino} · <span className={`badge b-${c.estado}`}>{c.estado.replace("_"," ")}</span></div>
              <div style={{fontSize:11,color:C.grisM,marginTop:3}}>🏢 {c.cliente} · Recogida: {c.fecha}</div>
              <div style={{display:"flex",gap:7,marginTop:7,flexWrap:"wrap"}}>
                <button className="btn btn-sm btn-ghost" onClick={()=>onDetalle(c)}>👁 Ver</button>
                {c.estado==="asignada"&&<button className="btn btn-sm btn-primary" onClick={()=>{iniciarViaje(c.id);showToast("Viaje iniciado — seguimiento GPS activado");}}>▶️ Iniciar viaje</button>}
                {c.estado==="en_transito"&&<button className="btn btn-sm btn-oro" onClick={()=>setVista("seguimiento")}>📍 Ver seguimiento</button>}
                {c.estado==="en_transito"&&<button className="btn btn-sm btn-ghost" onClick={()=>{confirmarEntregaManual(c.id);showToast("Entrega confirmada — pago liberado");}}>✅ Confirmar entrega</button>}
              </div>
            </div>
            <div style={{textAlign:"right",flexShrink:0}}>
              <div style={{fontFamily:"'Sora',sans-serif",fontSize:19,color:C.naranja}}>{fmtMoneda(c.precioAcordado)}</div>
              <div style={{fontSize:10,color:C.grisM}}>Pago {c.pago.estado}</div>
            </div>
          </div>
        ))}
      </div>
    </>
  );
}

// ─── SEGUIMIENTO GPS ────────────────────────────────────────────────────────
function CorridorTrack({carga}) {
  const oi = PAIS_IDX[carga.paisOrigen], di = PAIS_IDX[carga.paisDestino];
  const lo = Math.min(oi,di), hi = Math.max(oi,di);
  const pos = oi + (di-oi)*(carga.progreso/100);
  const pct = (pos/(PAISES.length-1))*100;
  const eta = carga.estado==="en_transito" ? Math.max(1,Math.round((100-carga.progreso)/10)) : null;
  return (
    <div className="corridor">
      <div className="corridor-line">
        <div className="corridor-fill" style={{width:`${pct}%`}}/>
        <div className="corridor-truck" style={{left:`${pct}%`}}>🚛</div>
      </div>
      <div className="corridor-ticks">
        {PAISES.map((p,i)=>(
          <div key={p} className={`corridor-tick${i>=lo&&i<=hi?" active":""}`} style={{left:`${(i/(PAISES.length-1))*100}%`}}>
            <div className="ct-dot"/><div className="ct-label">{p}</div>
          </div>
        ))}
      </div>
      <div className="trk-meta" style={{marginTop:34}}>
        <div className="tm">Progreso: <b>{carga.progreso}%</b></div>
        {eta!=null && <div className="tm">ETA estimada: <b>~{eta} h</b></div>}
        <div className="tm">Pago: <b>{carga.pago.estado}</b></div>
      </div>
    </div>
  );
}

function Seguimiento({usuario, cargas, iniciarViaje, confirmarEntregaManual}) {
  const mios = cargas.filter(c=>{
    const esParticipante = usuario.tipo==="cliente" ? c.clienteId===usuario.id : c.transportistaId===usuario.id;
    return esParticipante && ["asignada","en_transito"].includes(c.estado);
  });
  return (
    <>
      {mios.length===0&&<div className="empty"><div className="ei">📍</div>
        <p>No tienes viajes en curso</p><small>Aquí verás el seguimiento GPS en tiempo real de tus cargas asignadas</small></div>}
      {mios.map(c=>(
        <div className="trk-card" key={c.id}>
          <div className="trk-hd">
            <div>
              <div className="trk-title">{TCI[c.tipoCarga]} {c.tipoCarga} · {c.peso} {c.unidadPeso}</div>
              <div className="trk-sub">{c.ciudadOrigen}, {c.paisOrigen} → {c.ciudadDestino}, {c.paisDestino}</div>
              <div className="trk-sub">{usuario.tipo==="cliente"?`Transportista: ${c.transportistaNombre}`:`Cliente: ${c.cliente}`}</div>
            </div>
            <span className={`badge b-${c.estado}`}>{c.estado==="asignada"?"Esperando inicio":"En tránsito"}</span>
          </div>
          <CorridorTrack carga={c}/>
          {usuario.tipo==="transportista"&&c.estado==="asignada"&&(
            <button className="btn btn-sm btn-primary" style={{marginTop:10}} onClick={()=>iniciarViaje(c.id)}>▶️ Iniciar viaje</button>
          )}
          {usuario.tipo==="transportista"&&c.estado==="en_transito"&&(
            <button className="btn btn-sm btn-ghost" style={{marginTop:10}} onClick={()=>confirmarEntregaManual(c.id)}>✅ Confirmar entrega</button>
          )}
        </div>
      ))}
    </>
  );
}

// ─── MENSAJERÍA ───────────────────────────────────────────────────────────
function Mensajeria({usuario, convos, setConvos, usuarios, cargas, addNotif, showToast, asignarCarga}) {
  const [selConvo, setSelConvo] = useState(null);
  const [texto, setTexto] = useState("");
  const [ofertaVal, setOfertaVal] = useState("");
  const [showOferta, setShowOferta] = useState(false);
  const endRef = useRef(null);

  const misConvos = convos.filter(c=>c.participantes.includes(usuario.id));
  const convo = misConvos.find(c=>c.id===selConvo) || misConvos[0];

  useEffect(()=>{if(misConvos.length>0&&!selConvo)setSelConvo(misConvos[0].id);},[misConvos.length]);
  useEffect(()=>{endRef.current?.scrollIntoView({behavior:"smooth"});},[convo?.mensajes?.length]);

  const otro = (c) => c ? usuarios.find(u=>c.participantes.find(p=>p!==usuario.id)===u.id) : null;

  const enviar = () => {
    if(!texto.trim()||!convo) return;
    const msg = {id:uid(),de:usuario.id,texto:texto.trim(),ts:new Date().toISOString()};
    setConvos(cs=>cs.map(c=>c.id===convo.id?{...c,mensajes:[...c.mensajes,msg]}:c));
    const dest = otro(convo);
    if(dest) addNotif(dest.id,"mensaje","Nuevo mensaje de "+usuario.nombre,texto.trim().slice(0,50));
    setTexto("");
  };

  const enviarOferta = () => {
    const val = parseInt(ofertaVal);
    if(!val||val<1) return;
    const msg = {id:uid(),de:usuario.id,tipo:"oferta",precio:val,ts:new Date().toISOString(),estado:"pendiente"};
    setConvos(cs=>cs.map(c=>c.id===convo.id?{...c,mensajes:[...c.mensajes,msg]}:c));
    const dest = otro(convo);
    if(dest) addNotif(dest.id,"oferta","Nueva cotización de "+usuario.nombre,"$"+val.toLocaleString()+" por el viaje");
    setOfertaVal(""); setShowOferta(false);
    showToast("Cotización enviada: $"+val.toLocaleString());
  };

  const responderOferta = (msgId, accion) => {
    const ofertaMsg = convo.mensajes.find(m=>m.id===msgId);
    setConvos(cs=>cs.map(c=>{
      if(c.id!==convo.id) return c;
      const msgs = c.mensajes.map(m=>m.id===msgId?{...m,estado:accion}:m);
      return {...c,mensajes:msgs};
    }));
    if(accion==="aceptada"&&ofertaMsg){
      const carga = cargas.find(c=>c.id===convo.cargaId);
      const transportista = usuario.tipo==="cliente" ? otro(convo) : usuario;
      if(carga){
        asignarCarga(carga.id, transportista.id, transportista.nombre, ofertaMsg.precio);
      }
      const dest = otro(convo);
      if(dest) addNotif(dest.id,"oferta","✅ Cotización aceptada","Tu cotización de $"+ofertaMsg.precio.toLocaleString()+" fue aceptada");
      showToast("✅ Cotización aceptada — viaje asignado");
    } else {
      showToast("Cotización rechazada");
    }
  };

  const carga = convo ? cargas.find(c=>c.id===convo?.cargaId) : null;

  return (
    <div className="msg-layout">
      <div className="convos">
        <div className="convos-head">
          💬 Conversaciones
          <span style={{fontSize:12,color:C.grisM,fontWeight:400}}>{misConvos.length}</span>
        </div>
        {misConvos.length===0&&<div className="empty"><div className="ei">💬</div>
          <p>Sin conversaciones</p><small>Contacta desde el mercado de cargas</small></div>}
        {misConvos.map(c=>{
          const o = otro(c);
          const last = c.mensajes[c.mensajes.length-1];
          const unread = c.mensajes.filter(m=>m.de!==usuario.id&&!m.leido).length;
          return (
            <div key={c.id} className={`convo-item${selConvo===c.id?" on":""}`} onClick={()=>setSelConvo(c.id)}>
              <div className="ci-top">
                <span className="ci-name">{o?.nombre||"Usuario"}</span>
                <span className="ci-time">{last?fmtTime(last.ts):""}</span>
              </div>
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                <span className="ci-last">
                  {last?(last.tipo==="oferta"?`💰 Cotización: $${last.precio?.toLocaleString()}`:last.texto):"Sin mensajes"}
                </span>
                {unread>0&&<span className="ci-unread">{unread}</span>}
              </div>
            </div>
          );
        })}
      </div>

      {convo ? (
        <div className="chat-area">
          <div className="chat-head">
            <div className="ch-av">
              {otro(convo)?.selfie?<img src={otro(convo).selfie} alt="av"/>:TI[otro(convo)?.tipo]}
            </div>
            <div>
              <div className="ch-name">{otro(convo)?.nombre}</div>
              <div className="ch-role">{otro(convo)?.subtipo}
                {otro(convo)?.verificado&&" · ✅ Verificado"}
              </div>
            </div>
            {carga&&(
              <div style={{marginLeft:"auto",background:C.crema,borderRadius:8,padding:"5px 10px",fontSize:11}}>
                {TCI[carga.tipoCarga]} {carga.tipoCarga} · {carga.paisOrigen} → {carga.paisDestino}
              </div>
            )}
          </div>

          <div className="messages">
            {convo.mensajes.length===0&&<div style={{textAlign:"center",color:C.grisM,fontSize:13,margin:"auto"}}>
              Envía un mensaje para coordinar el viaje</div>}
            {convo.mensajes.map(m=>{
              const mine = m.de===usuario.id;
              if(m.tipo==="oferta") return (
                <div key={m.id} className={`msg-offer${mine?" mine":""}`}>
                  <div className="mo-label">{mine?"Tu cotización enviada":"Cotización recibida"}</div>
                  <div className="mo-price">{fmtMoneda(m.precio)} <span style={{fontSize:12,fontFamily:"Inter",color:C.grisM}}>por el viaje</span></div>
                  <div style={{fontSize:11,color:C.grisM,marginTop:2}}>{fmtTime(m.ts)}</div>
                  {!mine && m.estado==="pendiente"&&(
                    <div className="mo-btns">
                      <button className="btn btn-sm btn-primary" onClick={()=>responderOferta(m.id,"aceptada")}>✅ Aceptar</button>
                      <button className="btn btn-sm btn-danger" onClick={()=>responderOferta(m.id,"rechazada")}>❌ Rechazar</button>
                    </div>
                  )}
                  {m.estado&&m.estado!=="pendiente"&&(
                    <div style={{marginTop:6,fontSize:11,fontWeight:700,color:m.estado==="aceptada"?C.verde:C.rojo}}>
                      {m.estado==="aceptada"?"✅ Aceptada":"❌ Rechazada"}
                    </div>
                  )}
                </div>
              );
              return (
                <div key={m.id} className={`msg ${mine?"mine":"theirs"}`}>
                  {m.texto}
                  <div className="msg-time">{fmtTime(m.ts)}</div>
                </div>
              );
            })}
            <div ref={endRef}/>
          </div>

          {showOferta&&(
            <div className="offer-bar">
              <span style={{fontSize:12,fontWeight:700,color:C.marino}}>💰 Cotización $</span>
              <input type="number" placeholder="ej. 950" value={ofertaVal}
                onChange={e=>setOfertaVal(e.target.value)}
                onKeyDown={e=>e.key==="Enter"&&enviarOferta()} />
              <button className="btn btn-sm btn-oro" onClick={enviarOferta}>Enviar cotización</button>
              <button className="btn btn-sm btn-ghost" onClick={()=>setShowOferta(false)}>Cancelar</button>
            </div>
          )}

          <div className="chat-input">
            <button className="btn btn-sm btn-oro" onClick={()=>setShowOferta(v=>!v)} title="Enviar cotización">💰</button>
            <textarea rows={1} placeholder="Escribe un mensaje…" value={texto}
              onChange={e=>setTexto(e.target.value)}
              onKeyDown={e=>{if(e.key==="Enter"&&!e.shiftKey){e.preventDefault();enviar();}}} />
            <button className="btn btn-sm btn-primary" onClick={enviar}>Enviar →</button>
          </div>
        </div>
      ) : (
        <div style={{display:"flex",alignItems:"center",justifyContent:"center",flex:1}}>
          <div className="empty"><div className="ei">💬</div>
            <p>Selecciona una conversación</p>
            <small>O contacta a alguien desde el mercado de cargas</small></div>
        </div>
      )}
    </div>
  );
}

// ─── NOTIFICACIONES ───────────────────────────────────────────────────────
function NotifPanel({notifs, onClose, setVista}) {
  const ICONS = {mensaje:"💬",oferta:"💰",sistema:"📢"};
  return (
    <div className="notif-panel">
      <div className="np-head">
        <h3>🔔 Notificaciones</h3>
        <button style={{background:"none",border:"none",cursor:"pointer",fontSize:16,color:C.grisM}} onClick={onClose}>✕</button>
      </div>
      <div className="np-list">
        {notifs.length===0&&<div className="empty" style={{padding:"28px 0"}}><div className="ei">🔔</div>
          <p>Sin notificaciones</p></div>}
        {notifs.map(n=>(
          <div key={n.id} className={`notif-item${!n.leida?" unread":""}`}
            onClick={()=>{if(n.tipo==="mensaje"||n.tipo==="oferta")setVista("mensajes");onClose();}}>
            <span className="ni-icon">{ICONS[n.tipo]||"📢"}</span>
            <div className="ni-body">
              <div className="ni-title">{n.titulo}</div>
              <div className="ni-sub">{n.sub}</div>
              <div className="ni-time">{fmtTime(n.ts)}</div>
            </div>
            {!n.leida&&<div style={{width:8,height:8,borderRadius:"50%",background:"#ef4444",flexShrink:0,marginTop:4}}/>}
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── HISTORIAL ────────────────────────────────────────────────────────────
function Historial({usuario, historial}) {
  const mis = historial.filter(h=>h.clienteId===usuario.id||h.transportistaId===usuario.id);
  return (
    <>
      {mis.length===0&&<div className="empty"><div className="ei">📜</div>
        <p>Sin viajes completados</p><small>Las entregas confirmadas aparecerán aquí</small></div>}
      <div className="tx-list">
        {mis.map(h=>(
          <div key={h.id} className="tx-item">
            <div className="tx-icon">{TCI[h.tipoCarga]||"📦"}</div>
            <div className="tx-info">
              <div className="tx-title">{h.tipoCarga} · {usuario.tipo==="cliente"?`Transportado por ${h.transportista}`:`Para ${h.cliente}`}</div>
              <div className="tx-sub">{h.ruta} · {h.fecha} · <span className="badge b-verif">{h.estado}</span></div>
            </div>
            <div className="tx-price">
              <div className="tx-val">{fmtMoneda(h.monto)}</div>
              <div className="tx-date">Pago liberado</div>
            </div>
          </div>
        ))}
      </div>
    </>
  );
}

// ─── PERFIL ───────────────────────────────────────────────────────────────
function Perfil({usuario, setUsuario, setUsuarios, showToast}) {
  const [nombre, setNombre] = useState(usuario.nombre);
  const [tel, setTel] = useState(usuario.telefono||"");
  const [selfie, setSelfie] = useState(usuario.selfie);

  const handleSelfie = (e) => {
    const file = e.target.files[0]; if(!file) return;
    const reader = new FileReader();
    reader.onload = ev => setSelfie(ev.target.result);
    reader.readAsDataURL(file);
  };

  const guardar = () => {
    const upd = {...usuario,nombre,telefono:tel,selfie};
    setUsuario(upd);
    setUsuarios(us=>us.map(u=>u.id===usuario.id?upd:u));
    showToast("Perfil actualizado");
  };

  return (
    <div className="profile-card">
      <div style={{textAlign:"center",marginBottom:24}}>
        <div className="profile-av">
          {selfie?<img src={selfie} alt="av"/>:TI[usuario.tipo]}
        </div>
        <label style={{cursor:"pointer",display:"inline-block",marginTop:8,
          padding:"6px 14px",background:C.gris,borderRadius:8,fontSize:12,fontWeight:600,color:C.marino}}>
          📷 Cambiar foto
          <input type="file" accept="image/*" style={{display:"none"}} onChange={handleSelfie} />
        </label>
        <div style={{marginTop:10}}>
          <span className={`badge ${usuario.verificado?"b-verif":"b-noVerif"}`}>
            {usuario.verificado?"✅ Cuenta verificada":"⚠️ Cuenta sin verificar"}
          </span>
        </div>
      </div>

      <div className="field"><label>Nombre / Empresa</label>
        <input value={nombre} onChange={e=>setNombre(e.target.value)} /></div>
      <div className="field"><label>Correo electrónico</label>
        <input value={usuario.email} disabled style={{opacity:.6,cursor:"not-allowed"}} /></div>
      <div className="field"><label>Teléfono</label>
        <input value={tel} onChange={e=>setTel(e.target.value)} placeholder="+(504) 9xxx-xxxx" /></div>
      <div className="field"><label>Tipo de cuenta</label>
        <input value={usuario.subtipo} disabled style={{opacity:.6,cursor:"not-allowed"}} /></div>
      {usuario.tipo==="transportista"&&<div className="fgrid">
        <div className="field"><label>Vehículo</label>
          <input value={usuario.vehiculo||""} disabled style={{opacity:.6,cursor:"not-allowed"}} /></div>
        <div className="field"><label>Capacidad</label>
          <input value={usuario.capacidad?`${usuario.capacidad} ton`:""} disabled style={{opacity:.6,cursor:"not-allowed"}} /></div>
        <div className="field full"><label>Placa</label>
          <input value={usuario.placa||""} disabled style={{opacity:.6,cursor:"not-allowed"}} /></div>
      </div>}

      <button className="btn btn-primary" onClick={guardar} style={{marginTop:4}}>💾 Guardar cambios</button>
    </div>
  );
}

// ─── MODAL DETALLE ─────────────────────────────────────────────────────────
function ModalCarga({carga:c, onClose, usuario, usuarios, onContactar}) {
  const pub = usuarios.find(u=>u.id===c.clienteId);
  const puedeContactar = usuario.tipo==="cliente" ? c.clienteId!==usuario.id : true;
  return (
    <div className="overlay" onClick={onClose}>
      <div className="modal" onClick={e=>e.stopPropagation()}>
        <div className="modal-hd">
          <div>
            <span className={`badge b-${c.estado}`}>{c.estado.replace("_"," ")}</span>
            <h2 style={{marginTop:6}}>{TCI[c.tipoCarga]} {c.tipoCarga}</h2>
          </div>
          <button className="close-btn" onClick={onClose}>✕</button>
        </div>
        <div style={{display:"flex",alignItems:"center",gap:10,padding:"10px 0",borderBottom:`1px solid ${C.gris}`,marginBottom:8}}>
          <div style={{width:38,height:38,borderRadius:"50%",background:C.gris,display:"flex",
            alignItems:"center",justifyContent:"center",fontSize:18,overflow:"hidden",flexShrink:0}}>
            {pub?.selfie?<img src={pub.selfie} style={{width:"100%",height:"100%",objectFit:"cover"}} alt="av"/>:"🏢"}
          </div>
          <div>
            <div style={{fontWeight:700,fontSize:14,color:C.marino}}>{c.cliente}</div>
            <span className={`badge ${pub?.verificado?"b-verif":"b-noVerif"}`}>
              {pub?.verificado?"✅ Verificado":"⚠️ Sin verificar"}</span>
          </div>
        </div>
        <div className="irow"><span className="ik">Ruta</span><span className="iv">{c.ciudadOrigen} → {c.ciudadDestino}</span></div>
        <div className="irow"><span className="ik">Peso</span><span className="iv">{c.peso} {c.unidadPeso}</span></div>
        <div className="irow"><span className="ik">Vehículo requerido</span><span className="iv">{c.vehiculoReq}</span></div>
        <div className="irow"><span className="ik">Fecha de recogida</span><span className="iv">{c.fecha}</span></div>
        <div className="irow"><span className="ik">Presupuesto</span>
          <span className="iv" style={{fontFamily:"'Sora',sans-serif",fontSize:18,color:C.naranja}}>{c.precioAcordado?fmtMoneda(c.precioAcordado):(c.presupuesto?fmtMoneda(c.presupuesto):"Abierto a cotización")}</span></div>
        {c.transportistaNombre&&<div className="irow"><span className="ik">Transportista</span><span className="iv">{c.transportistaNombre}</span></div>}
        {c.descripcion&&<div className="irow"><span className="ik">Descripción</span>
          <span className="iv" style={{maxWidth:"60%",textAlign:"right"}}>{c.descripcion}</span></div>}
        {puedeContactar&&c.estado!=="cancelada"&&(
          <button className="btn btn-primary" style={{width:"100%",marginTop:14}} onClick={onContactar}>
            💬 Contactar
          </button>
        )}
      </div>
    </div>
  );
}
