// 本地 Mermaid 初始化配置
// 替代 https://unpkg.com/mermaid@11.10.1/dist/mermaid.min.js 的远程加载

document.addEventListener('DOMContentLoaded', function() {
  // 检查 Mermaid 是否已加载
  if (typeof mermaid !== 'undefined') {
    // 初始化 Mermaid 配置
    mermaid.initialize({
      startOnLoad: true,
      theme: 'default',
      themeVariables: {
        primaryColor: '#ff9999',
        primaryTextColor: '#fff',
        primaryBorderColor: '#ff6666',
        lineColor: '#5D6D7E',
        secondaryColor: '#006100',
        tertiaryColor: '#fff'
      },
      flowchart: {
        useMaxWidth: true,
        htmlLabels: true,
        curve: 'basis'
      },
      securityLevel: 'loose'
    });
  }
});