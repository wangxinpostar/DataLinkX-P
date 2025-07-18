import clearIcon from '@/assets/clear.png'

function getFormatter (value) {
  return function (params) {
    let result = value // 初始值
    const regex = /\{c\|toFixed\((\d+)\)\}/
    const match = value.match(regex)
    if (match) {
      const decimalPlaces = parseInt(match[1], 10) // 获取小数位数
      const numericValue = parseFloat(params.value || params.data?.value) // 获取数值
      if (!isNaN(numericValue)) {
        result = numericValue.toFixed(decimalPlaces) // 格式化数值
      }
    } else {
      // 替换标准占位符
      result = result
        .replace('{c}', params.value || params.data?.value)
        .replace('{a}', params.seriesName)
        .replace('{b}', params.name)
    }

    return result
  }
}

export function renderChart (VueIns) {
  const seriesData = []
  const xAxisData = VueIns.xAxisData

  VueIns.selectedYIndex.forEach(YIndex => {
    const ChartStyle = VueIns.chartStyles[YIndex] || {}
    const labelConfig = {
      show: ChartStyle.showDataLabel,
      position: ChartStyle.position,
      color: ChartStyle.labelColor?.hex,
      formatter: (params) => {
        return getFormatter(ChartStyle.formatter)(params)
      },
      fontSize: ChartStyle.fontSize,
      fontWeight: ChartStyle.fontWeight
    }

    switch (VueIns.chartType) {
      case 'scatter':
        seriesData.push({
          name: YIndex,
          type: 'scatter',
          data: xAxisData.map(XIndex => [XIndex, VueIns.chartData[XIndex][YIndex]]),
          itemStyle: { color: ChartStyle.lineColor?.hex },
          label: labelConfig,
          markPoint: { data: VueIns.showMarkPoint ? VueIns.markPointData : [] },
          markLine: { data: VueIns.showMarkLine ? VueIns.markLineData : [] }
        })
        break

      case 'bar':
        seriesData.push({
          name: YIndex,
          type: 'bar',
          data: xAxisData.map(XIndex => VueIns.chartData[XIndex][YIndex]),
          itemStyle: { color: ChartStyle.lineColor?.hex },
          label: labelConfig,
          markPoint: { data: VueIns.showMarkPoint ? VueIns.markPointData : [] },
          markLine: { data: VueIns.showMarkLine ? VueIns.markLineData : [] }
        })
        break

      case 'line':
        seriesData.push({
          name: YIndex,
          type: 'line',
          data: xAxisData.map(XIndex => VueIns.chartData[XIndex][YIndex]),
          lineStyle: { color: ChartStyle.lineColor?.hex, type: ChartStyle.lineStyle },
          label: labelConfig,
          smooth: ChartStyle.smooth,
          markPoint: { data: VueIns.showMarkPoint ? VueIns.markPointData : [] },
          markLine: { data: VueIns.showMarkLine ? VueIns.markLineData : [] }
        })
        // console.log('seriesData', seriesData)
        // console.log('xAxisData', xAxisData)
        break

      case 'pie':
        seriesData.push({
          name: YIndex,
          type: 'pie',
          radius: ChartStyle.radius || '50%',
          center: ChartStyle.center || ['50%', '50%'],
          data: xAxisData.map(XIndex => ({
            name: XIndex,
            value: VueIns.chartData[XIndex][YIndex]
          })),
          label: labelConfig
        })
        break

      default:
        console.warn(`Unsupported chart type: ${VueIns.chartType}`)
    }
  })

  const option = {
    title: { text: VueIns.chartTitle },
    tooltip: { trigger: VueIns.chartType === 'pie' ? 'item' : 'axis' },
    legend: VueIns.chartType === 'pie' ? { data: xAxisData } : {
      data: VueIns.selectedYIndex,
      [VueIns.legendPosition]: VueIns.legendPosition
    },
    xAxis: VueIns.chartType !== 'pie' ? {
      type: 'category',
      data: xAxisData,
      name: VueIns.xAxisTitle,
      axisLabel: { rotate: VueIns.xAxisRotate }
    } : undefined,
    yAxis: VueIns.chartType !== 'pie' ? {
      type: 'value',
      name: VueIns.yAxisTitle,
      min: VueIns.yMin,
      max: VueIns.yMax,
      splitLine: { show: VueIns.yAxisSplitLine }
    } : undefined,
    series: seriesData,
    toolbox: VueIns.showToolbox ? {
      top: '10px',
      right: '10px',
      feature: {
        saveAsImage: {},
        dataZoom: { show: true },
        restore: {},
        myTool1: {
          show: true,
          title: '清空',
          icon: 'image://' + clearIcon,
          onclick: function () {
            VueIns.clearChart()
          }
        }
      }
    } : null
  }
  VueIns.chart.setOption(option, true)
  setTimeout(() => { VueIns.chart.resize() }, 300)
}
