import { useEffect, useState } from 'react'
import { useQueryCache } from 'react-query'
import { usePaginatedRequestQuery } from '@/hooks'
import { SolutionChannel } from '@/channels/solutionChannel'
import { IterationStatus } from '@/components/types'
import type {
  RealtimeFeedbackModalProps,
  ResolvedIteration,
} from '../RealtimeFeedbackModal'

const REFETCH_INTERVAL = 2000
const PENDING_STATUS = [
  IterationStatus.DELETED,
  IterationStatus.UNTESTED,
  IterationStatus.TESTING,
  IterationStatus.ANALYZING,
]

export function useGetLatestIteration({
  request,
  submission,
  solution,
}: Pick<RealtimeFeedbackModalProps, 'request' | 'submission' | 'solution'>): {
  latestIteration: ResolvedIteration | undefined
  checkStatus: string
} {
  const [latestIteration, setLatestIteration] = useState<ResolvedIteration>()
  const [checkStatus, setCheckStatus] = useState('loading')

  const queryCache = useQueryCache()
  const CACHE_KEY = `editor-${solution.uuid}-feedback`

  const [queryEnabled, setQueryEnabled] = useState(false)

  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: ResolvedIteration[]
  }>(CACHE_KEY, {
    ...request,
    options: {
      ...request?.options,
      refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
    },
  })
  useEffect(() => {
    const lastIteration =
      resolvedData?.iterations[resolvedData.iterations.length - 1]
    if (
      lastIteration &&
      submission?.uuid === lastIteration?.submissionUuid &&
      !PENDING_STATUS.includes(lastIteration.status)
    ) {
      setLatestIteration(lastIteration)
      setCheckStatus(lastIteration.status)
    } else {
      setCheckStatus('loading')
      setLatestIteration(undefined)
    }
  }, [latestIteration, resolvedData, submission])

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { uuid: solution.uuid },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, { iterations: response.iterations })
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, queryCache, solution])

  useEffect(() => {
    if (!latestIteration) {
      return
    }

    switch (latestIteration.status) {
      case IterationStatus.DELETED:
      case IterationStatus.UNTESTED:
      case IterationStatus.TESTING:
      case IterationStatus.ANALYZING:
        setQueryEnabled(true)
        break
      default:
        setQueryEnabled(false)
        break
    }
  }, [latestIteration])

  return { latestIteration, checkStatus }
}
